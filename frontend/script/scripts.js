// scripts.js

// Функция проверки аутентификации пользователя
const isLoggedIn = () =>
  document.cookie.split(';').some(c => c.trim().startsWith('jwt='));

// Функция для перенаправления неавторизованных пользователей на страницу логина
const redirectToLogin = () => {
  window.location.replace(
    `/login.html?redirect=${encodeURIComponent(window.location.href)}`
  );
};

// Инициализация страницы каталога товаров
function initCatalogPage() {
  const itemsContainer = document.getElementById('catalog-items');
  let currentPage = 1;
  let totalPages = null;
  let isLoading = false;

  // Функция рендеринга карточки товара с использованием шаблонных строк
  const createProductCard = (item) => {
    const card = document.createElement('div');
    card.className = 'card';

    // Формирование контента карточки через innerHTML
    card.innerHTML = `
      <a href="item.html?id=${item.id}" class="card-content">
        <div class="card-image">
          <img src="https://stroylomay.shop/img/${item.img_url}" alt="${item.name}" loading="lazy">
        </div>
        <div class="card-info">
          <div class="card-text">
            <h3 class="card-title">${item.name}</h3>
            <p class="card-desc">${item.description && item.description.length > 60
        ? item.description.substring(0, 60) + '...'
        : item.description || ''
      }</p>
          </div>
          <div class="card-bottom">
            <p class="card-price">${item.price} ₽/День</p>
            <p class="card-warehouse">
              Склад: <a href="wirehouse.html?id=${item.warehouse_id || ''}">${item.warehouse_name}</a>
            </p>
          </div>
        </div>
      </a>
    `;
    // Отдельный блок для кнопки "Добавить в корзину"
    const buttonBlock = document.createElement('div');
    buttonBlock.className = 'card-button';
    const addBtn = document.createElement('button');
    addBtn.textContent = 'Добавить в корзину';
    addBtn.className = 'add-to-cart';
    addBtn.dataset.id = item.id;
    buttonBlock.appendChild(addBtn);
    card.appendChild(buttonBlock);
    return card;
  };

  const appendItems = (items) => {
    items.forEach(item => {
      itemsContainer.appendChild(createProductCard(item));
    });
  };

  // Асинхронная загрузка данных товаров с API
  const loadItems = async (page) => {
    if (isLoading) return;
    isLoading = true;
    try {
      const response = await fetch(`https://stroylomay.shop/api/v1/items?page=${page}`);
      const data = await response.json();
      const items = data.items || data;
      if (items && items.length) {
        appendItems(items);
        currentPage = page;
        totalPages = data.total_pages ?? currentPage;
      } else {
        totalPages = currentPage;
      }
    } catch (error) {
      console.error('Ошибка загрузки товаров:', error);
    } finally {
      isLoading = false;
    }
  };

  // Первоначальная загрузка первой страницы товаров
  loadItems(1);

  // Бесконечная прокрутка
  window.addEventListener('scroll', () => {
    const nearBottom =
      window.innerHeight + window.scrollY >= document.body.offsetHeight - 100;
    if (nearBottom && !isLoading && (totalPages === null || currentPage < totalPages)) {
      loadItems(currentPage + 1);
    }
  });

  // Делегирование событий для добавления товара в корзину
  itemsContainer.addEventListener('click', (e) => {
    if (e.target.classList.contains('add-to-cart')) {
      e.preventDefault();
      handleAddToCart(e.target.dataset.id);
    }
  });
}

// Инициализация страницы отдельного товара
async function initItemPage() {
  const params = new URLSearchParams(window.location.search);
  const itemId = params.get('id');
  if (!itemId) return;
  try {
    const response = await fetch(`https://stroylomay.shop/api/v1/items?id=${itemId}`);
    const data = await response.json();

    document.getElementById('item-name').textContent = data.name;
    document.getElementById('item-desc').textContent = data.description;
    document.getElementById('item-price').textContent = data.price;
    document.getElementById('item-penalty').textContent = data.late_penalty;
    document.getElementById('item-active').textContent = data.active ? 'Да' : 'Нет';

    const imgElem = document.getElementById('item-image');
    if (imgElem) {
      imgElem.src = `https://stroylomay.shop/img/${data.img_url}`;
      imgElem.alt = data.name;
    }
    const whLink = document.getElementById('item-warehouse-link');
    if (whLink) {
      whLink.textContent = data.warehouse_name;
      if (data.warehouse_id) {
        whLink.href = `wirehouse.html?id=${data.warehouse_id}`;
      } else {
        whLink.removeAttribute('href');
        whLink.style.cursor = 'default';
      }
    }
    document.title = `${data.name} – Строй Ломай`;
  } catch (error) {
    console.error('Ошибка загрузки товара:', error);
  }
}

// Инициализация страницы склада
async function initWirehousePage() {
  const params = new URLSearchParams(window.location.search);
  const whId = params.get('id');
  if (!whId) return;
  try {
    const response = await fetch(`https://stroylomay.shop/api/v1/wirehouses?id=${whId}`);
    const data = await response.json();

    document.getElementById('wh-name').textContent = data.name;
    document.getElementById('wh-phone').textContent = data.phone;
    document.getElementById('wh-email').textContent = data.email;
    document.getElementById('wh-address').textContent = data.address;
    document.getElementById('wh-active').textContent = data.active ? 'Да' : 'Нет';
    document.title = `${data.name} – Строй Ломай`;
  } catch (error) {
    console.error('Ошибка загрузки склада:', error);
  }
}

// Обработчик добавления товара в корзину
async function handleAddToCart(itemId) {
  if (!isLoggedIn()) {
    alert('Пожалуйста, авторизуйтесь для добавления товара в корзину');
    return;
  }
  try {
    const response = await fetch(`https://stroylomay.shop/api/v1/cart?id=${itemId}`, {
      method: 'POST',
      credentials: 'same-origin'
    });
    if (response.ok) {
      const cartIcon = document.querySelector('.cart-icon');
      if (cartIcon) {
        cartIcon.classList.add('shake');
        setTimeout(() => cartIcon.classList.remove('shake'), 500);
      }
    } else {
      console.error('Не удалось добавить в корзину. Статус:', response.status);
    }
  } catch (error) {
    console.error('Ошибка при добавлении в корзину:', error);
  }
}

// Регистрация пользователя
function register() {
  const regForm = document.getElementById("register-form");
  if (!regForm) return;

  regForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    // Получаем значения полей формы
    const firstname = document.getElementById("firstname").value.trim();
    const lastname = document.getElementById("lastname").value.trim();
    const loginValue = document.getElementById("login").value.trim();
    const email = document.getElementById("email").value.trim();
    const phone = document.getElementById("phone").value.trim();
    const password = document.getElementById("password").value;
    const passwordConfirm = document.getElementById("password-confirm").value;

    // Проверка паролей и базовая валидация email и телефона
    if (password !== passwordConfirm) {
      return alert("Пароли не совпадают!");
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return alert("Введите корректный email адрес.");
    }
    if (!/^7\d{10}$/.test(phone)) {
      return alert("Введите корректный телефонный номер вида 7XXXXXXXXXX.");
    }

    const registrationData = {
      login: loginValue,
      password,
      firstname,
      lastname,
      email,
      phone
    };

    try {
      const response = await fetch("https://stroylomay.shop/api/v1/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(registrationData)
      });
      if (!response.ok) {
        const errorText = await response.text();
        let errorMessage;
        try {
          const errorData = JSON.parse(errorText);
          errorMessage = errorData.message || response.statusText;
        } catch (e) {
          errorMessage = errorText || response.statusText;
        }
        throw new Error("Ошибка регистрации: " + errorMessage);
      }
      // Обрабатываем ответ (если он есть)
      const responseText = await response.text();
      let data = null;
      if (responseText) {
        try {
          data = JSON.parse(responseText);
        } catch (e) {
          data = responseText;
        }
      }
      alert("Регистрация прошла успешно. Теперь вы можете войти.");
      window.location.href = "/login.html";
    } catch (error) {
      console.error("Ошибка регистрации:", error);
      alert("Ошибка регистрации: " + error.message);
    }
  });
}

// Авторизация пользователя
function login() {
  const authForm = document.getElementById("auth-form");
  if (!authForm) return;

  authForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const loginValue = document.getElementById("login").value.trim();
    const password = document.getElementById("password").value;
    const credentials = { login: loginValue, password };

    try {
      const response = await fetch("https://stroylomay.shop/api/v1/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(credentials)
      });
      if (!response.ok) {
        throw new Error("Ошибка авторизации: " + response.statusText);
      }
      const data = await response.json();
      if (data.token) {
        document.cookie = `jwt=${data.token}; path=/;`;
        window.location.href = "/";
      } else {
        throw new Error("JWT токен не получен");
      }
    } catch (error) {
      console.error("Ошибка авторизации:", error);
      alert("Ошибка авторизации: " + error.message);
    }
  });
}

// Функция инициализации страницы аккаунта
async function initAccountPage() {
  try {
    const response = await fetch('https://stroylomay.shop/api/v1/account', { credentials: 'same-origin' });
    if (!response.ok) {
      throw new Error('Ошибка загрузки информации о пользователе: ' + response.statusText);
    }
    const data = await response.json();

    document.getElementById('account-id').textContent = data.id;
    document.getElementById('account-login').textContent = data.login;
    document.getElementById('account-firstname').textContent = data.firstname;
    document.getElementById('account-lastname').textContent = data.lastname;
    document.getElementById('account-phone').textContent = data.phone;
    document.getElementById('account-phone-verified').textContent = data.phone_verified ? '(Проверен)' : '(Не проверен)';
    document.getElementById('account-email').textContent = data.email;
    document.getElementById('account-email-verified').textContent = data.email_verified ? '(Проверен)' : '(Не проверен)';
    document.getElementById('account-passport').textContent = data.passport;
    document.getElementById('account-passport-verified').textContent = data.passport_verified ? '(Проверен)' : '(Не проверен)';
  } catch (err) {
    console.error('Ошибка загрузки информации о пользователе:', err);
    alert('Не удалось загрузить информацию о пользователе.');
  }
}

// Основной обработчик загрузки страницы
document.addEventListener('DOMContentLoaded', () => {
  const path = window.location.pathname;

  // Инициализация страниц авторизации и регистрации
  if (path.endsWith("login.html")) {
    login();
  } else if (path.endsWith("register.html")) {
    register();
  }

  // Инициализация страниц каталога, товара и склада
  if (path.endsWith('catalog.html')) {
    initCatalogPage();
  } else if (path.endsWith('item.html')) {
    initItemPage();
  } else if (path.endsWith('wirehouse.html')) {
    initWirehousePage();
  }

  // Если открыта страница аккаунта, проверяем наличие JWT
  if (path.endsWith('account.html')) {
    if (!isLoggedIn()) {
      redirectToLogin();
    } else {
      initAccountPage();
    }
  }
});
