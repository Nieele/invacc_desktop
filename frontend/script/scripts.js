// scripts.js

// Базовые константы
const API_BASE = 'https://stroylomay.shop/api/v1';
const IMG_BASE = 'https://stroylomay.shop/img';
const ITEMS_LIMIT = 20;

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
  let totalPages = 1;
  let isLoading = false;

  // Функция создания карточки товара
  const createProductCard = (item) => {
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `
      <a href="item.html?id=${item.id}" class="card-content">
        <div class="card-image">
          <img src="${IMG_BASE}/${item.img_url}" alt="${item.name}" loading="lazy">
        </div>
        <div class="card-info">
          <h3 class="card-title">${item.name}</h3>
          <div class="card-bottom">
            <p class="card-price">${item.price} ₽/день</p>
            <p class="card-warehouse">
              <a href="wirehouse.html?id=${item.warehouse_id}" class="warehouse-label">Склад:</a>
              <a href="wirehouse.html?id=${item.warehouse_id}">${item.warehouse_name}</a>
            </p>
          </div>
        </div>
      </a>`;

    // Кнопка "Добавить в корзину"
    const buttonBlock = document.createElement('div');
    buttonBlock.className = 'card-button';
    const addBtn = document.createElement('button');
    addBtn.textContent = 'Добавить в корзину';
    addBtn.className = 'add-to-cart';
    addBtn.dataset.id = item.id;
    buttonBlock.appendChild(addBtn);
    card.appendChild(buttonBlock);

    return card;
  };

  // Добавление массива товаров в контейнер
  const appendItems = (items) => {
    items.forEach(item => itemsContainer.appendChild(createProductCard(item)));
  };

  // Загрузка страницы товаров
  const loadItems = async (page) => {
    if (isLoading || page > totalPages) return;
    isLoading = true;
    try {
      const response = await fetch(`${API_BASE}/items?limit=${ITEMS_LIMIT}&page=${page}`);
      if (!response.ok) {
        console.error('Ошибка загрузки товаров. Статус:', response.status);
        return;
      }
      const json = await response.json();
      const items = json.data || [];
      // Надёжно извлекаем meta и links
      const meta = json.meta || {};
      const links = json.links || {};

      // Вычисляем общее число страниц
      const limit = meta.limit || ITEMS_LIMIT;
      const total = meta.total || 0;
      const pageIndex = meta.page || page;
      totalPages = Math.ceil(total / limit);
      currentPage = pageIndex;

      if (items.length) {
        appendItems(items);
      }
    } catch (error) {
      console.error('Ошибка при загрузке товаров:', error);
    } finally {
      isLoading = false;
    }
  };

  // Первая загрузка
  loadItems(1);

  // Бесконечная прокрутка
  window.addEventListener('scroll', () => {
    const nearBottom =
      window.innerHeight + window.scrollY >= document.body.offsetHeight - 100;
    if (nearBottom && !isLoading && currentPage < totalPages) {
      loadItems(currentPage + 1);
    }
  });

  // Обработка клика по кнопке "Добавить в корзину"
  itemsContainer.addEventListener('click', (e) => {
    if (e.target.classList.contains('add-to-cart')) {
      e.preventDefault();
      handleAddToCart(e.target, e.target.dataset.id);
    }
  });
}

// Инициализация страницы отдельного товара
async function initItemPage() {
  const params = new URLSearchParams(window.location.search);
  const itemId = params.get('id');
  if (!itemId) return;

  try {
    const res = await fetch(`${API_BASE}/items/${itemId}`);
    if (!res.ok) throw new Error(res.statusText);
    const json = await res.json();
    const item = json.data;

    const {
      name,
      description,
      price,
      late_penalty,
      active,
      img_url,
      warehouse
    } = item;

    document.getElementById('item-name').textContent = name;
    document.getElementById('item-desc').textContent = description;
    document.getElementById('item-price').textContent = price;
    document.getElementById('item-penalty').textContent = late_penalty;
    document.getElementById('item-active').textContent = active ? 'Да' : 'Нет';

    const imgElem = document.getElementById('item-image');
    if (imgElem) {
      imgElem.src = `${IMG_BASE}/${img_url}`;
      imgElem.alt = name;
    }

    const whLink = document.getElementById('item-warehouse-link');
    if (whLink) {
      whLink.textContent = warehouse.name;
      whLink.href = `wirehouse.html?id=${warehouse.id}`;
    }

    document.title = `${name} – Строй Ломай`;

    // Настраиваем кнопку "Добавить в корзину"
    const addToCartBtn = document.getElementById('add-to-cart-btn');
    if (addToCartBtn) {
      // Устанавливаем класс и ID товара
      addToCartBtn.className = 'add-to-cart';
      addToCartBtn.dataset.id = data.id;

      // Добавляем обработчик клика
      addToCartBtn.addEventListener('click', function () {
        handleAddToCart(this, this.dataset.id);
      });
    }
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
async function handleAddToCart(buttonElement, itemId) {
  if (!isLoggedIn()) {
    // Если пользователь не авторизован — проигрываем анимацию ошибки и выводим сообщение
    buttonElement.classList.add('error');
    setTimeout(() => buttonElement.classList.remove('error'), 1000);
    alert('Пожалуйста, авторизуйтесь для добавления товара в корзину');
    return;
  }
  try {
    // Преобразование itemId в число (целое число)
    const itemIdInt = parseInt(itemId, 10);
    const response = await fetch('https://stroylomay.shop/api/v1/cart', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ item_id: itemIdInt })
    });

    if (response.ok) {
      // Успешное добавление — проигрываем анимацию успеха
      buttonElement.classList.add('success');
      setTimeout(() => buttonElement.classList.remove('success'), 1000);
    } else {
      // Ошибка добавления — проигрываем анимацию ошибки и выводим информацию в консоль
      buttonElement.classList.add('error');
      setTimeout(() => buttonElement.classList.remove('error'), 1000);
      console.error('Не удалось добавить в корзину. Статус:', response.status);
    }
  } catch (error) {
    // При возникновении ошибки в запросе — проигрываем анимацию ошибки
    buttonElement.classList.add('error');
    setTimeout(() => buttonElement.classList.remove('error'), 1000);
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

// Функция загрузки информации о пользователе и рендеринга внутри .account-details
async function initAccountPage() {
  try {
    const response = await fetch('https://stroylomay.shop/api/v1/account', { credentials: 'same-origin' });
    if (!response.ok) throw new Error('Ошибка загрузки: ' + response.statusText);

    const d = await response.json();
    const rows = [
      { label: 'ID', id: 'account-id', value: d.id },
      { label: 'Логин', id: 'account-login', value: d.login },
      { label: 'Имя', id: 'account-firstname', value: d.firstname },
      { label: 'Фамилия', id: 'account-lastname', value: d.lastname },
      { label: 'Телефон', id: 'account-phone', value: d.phone, verified: d.phone_verified },
      { label: 'Email', id: 'account-email', value: d.email, verified: d.email_verified },
      { label: 'Паспорт', id: 'account-passport', value: d.passport, verified: d.passport_verified }
    ];

    /* --- строки с данными --- */
    const details = document.querySelector('.account-details');
    details.innerHTML = rows.map(r => `
      <div class="account-row">
        <div class="account-label">${r.label}:</div>
        <div class="account-value" id="${r.id}">${r.value ?? ''}</div>
        <div class="account-verification ${r.verified ? 'verified' : 'not-verified'}">
          ${r.verified !== undefined ? (r.verified ? 'Подтверждено' : 'Не&nbsp;подтверждено') : ''}
        </div>
      </div>`).join('');

    /* --- сводка статусов --- */
    const summary = document.querySelector('.verification-summary');
    summary.innerHTML = `
      <h2>Подтверждения</h2>
      <ul>
        <li><strong>Телефон:</strong> <span class="account-verification ${d.phone_verified ? 'verified' : 'not-verified'}">${d.phone_verified ? '✔️' : '❌'}</span></li>
        <li><strong>Email:</strong>   <span class="account-verification ${d.email_verified ? 'verified' : 'not-verified'}">${d.email_verified ? '✔️' : '❌'}</span></li>
        <li><strong>Паспорт:</strong> <span class="account-verification ${d.passport_verified ? 'verified' : 'not-verified'}">${d.passport_verified ? '✔️' : '❌'}</span></li>
      </ul>`;
  } catch (err) {
    console.error('Ошибка загрузки информации о пользователе:', err);
    alert('Не удалось загрузить информацию о пользователе.');
  }
}

// Функция инициализации редактирования аккаунта
function initAccountEdit() {
  const editBtn = document.getElementById('edit-btn');
  if (!editBtn) return;
  let isEditing = false;
  let cancelBtn = null;
  editBtn.addEventListener('click', () => {
    if (!isEditing) {
      // Переводим поля в режим редактирования: заменяем содержимое input'ами
      const fields = ['account-login', 'account-firstname', 'account-lastname', 'account-phone', 'account-email', 'account-passport'];
      fields.forEach(id => {
        const valueElem = document.getElementById(id);
        if (valueElem) {
          const currentValue = valueElem.textContent.trim();
          const input = document.createElement('input');
          input.type = 'text';
          input.value = currentValue;
          input.className = 'edit-input';
          input.id = id;  // сохраняем тот же ID
          valueElem.parentNode.replaceChild(input, valueElem);
        }
      });
      isEditing = true;
      editBtn.textContent = "Готово";
      // Добавляем кнопку Отмена
      cancelBtn = document.createElement('button');
      cancelBtn.textContent = "Отмена";
      cancelBtn.className = "btn btn--secondary";
      editBtn.parentNode.appendChild(cancelBtn);
      cancelBtn.addEventListener('click', () => {
        initAccountPage().then(() => {
          isEditing = false;
          editBtn.textContent = "Изменить информацию";
          if (cancelBtn) cancelBtn.remove();
        });
      });
    } else {
      // Собираем данные из input'ов
      const updateData = {
        login: document.getElementById('account-login').value.trim(),
        firstname: document.getElementById('account-firstname').value.trim(),
        lastname: document.getElementById('account-lastname').value.trim(),
        phone: document.getElementById('account-phone').value.trim(),
        email: document.getElementById('account-email').value.trim(),
        passport: document.getElementById('account-passport').value.trim()
      };
      fetch('https://stroylomay.shop/api/v1/account', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify(updateData)
      })
        .then(response => {
          if (!response.ok) {
            throw new Error('Ошибка обновления: ' + response.statusText);
          }
          return response.json();
        })
        .then(data => {
          alert('Информация успешно обновлена!');
          initAccountPage().then(() => {
            isEditing = false;
            editBtn.textContent = "Изменить информацию";
            if (cancelBtn) cancelBtn.remove();
          });
        })
        .catch(err => {
          console.error('Ошибка обновления аккаунта:', err);
          alert('Ошибка обновления: ' + err.message);
        });
    }
  });
}

// Инициализация страницы корзины
async function initCartPage() {
  // Проверяем, авторизован ли пользователь
  if (!isLoggedIn()) {
    redirectToLogin();
    return;
  }

  const cartItemsContainer = document.getElementById('cart-items');
  const cartEmptyElement = document.querySelector('.cart-empty');
  const cartSummaryElement = document.querySelector('.cart-summary');
  const cartTotalPriceElement = document.getElementById('cart-total-price');

  // Функция для создания карточки товара в корзине
  const createCartItemCard = (item) => {
    const {
      id,
      item_id,
      name,
      price,
      late_penalty,
      img_url,
      warehouse   // <-- здесь будет объект { id, name, … }
    } = item;

    const card = document.createElement('div');
    card.className = 'cart-item';
    card.dataset.id = id;
    card.dataset.itemId = item_id;
    card.dataset.href = `item.html?id=${item_id}`;

    card.innerHTML = `
      <div class="cart-item-image">
        <img src="${IMG_BASE}/${img_url}" alt="${name}" loading="lazy">
      </div>
      <div class="cart-item-details">
        <h3 class="cart-item-title">${name}</h3>
        <p class="cart-item-price">${price} ₽/день</p>
        <p class="cart-item-penalty">Штраф за просрочку: ${late_penalty} ₽</p>
        <p class="cart-item-warehouse">
          <a href="wirehouse.html?id=${warehouse.id}" class="warehouse-label">Склад:</a>
          <a href="wirehouse.html?id=${warehouse.id}">${warehouse.name}</a>
        </p>
      </div>
      <div class="cart-item-remove">
        <button class="btn-remove" data-id="${id}" data-item-id="${item_id}">Удалить</button>
      </div>
    `;

    // переход на страницу товара
    card.addEventListener('click', (e) => {
      if (!e.target.closest('.btn-remove') &&
        !e.target.closest('.cart-item-warehouse a')) {
        window.location.href = card.dataset.href;
      }
    });

    return card;
  };

  // Функция для загрузки данных о товаре по его ID
  const fetchItemDetails = async (itemId) => {
    const res = await fetch(`${API_BASE}/items/${itemId}`, { credentials: 'same-origin' });
    if (!res.ok) throw new Error(`Ошибка загрузки товара ID=${itemId}: ${res.statusText}`);
    const json = await res.json();
    // целиком объект data
    return json.data;
  };

  // Функция для удаления товара из корзины
  const removeFromCart = async (cartId, itemId) => {
    try {
      const response = await fetch('https://stroylomay.shop/api/v1/cart', {
        method: 'DELETE',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ item_id: parseInt(itemId, 10) })
      });

      if (!response.ok) {
        throw new Error(`Ошибка удаления товара: ${response.statusText}`);
      }

      // Удаляем элемент из DOM
      const itemElement = document.querySelector(`.cart-item[data-id="${cartId}"]`);
      if (itemElement) {
        itemElement.remove();
      }

      // Обновляем итоговую сумму
      updateCartTotal();

      // Проверяем, не опустела ли корзина
      if (cartItemsContainer.children.length === 0) {
        cartItemsContainer.classList.add('hide');
        cartSummaryElement.classList.add('hide');
        cartEmptyElement.classList.remove('hide');
      }

    } catch (error) {
      console.error('Ошибка при удалении товара из корзины:', error);
      alert('Не удалось удалить товар из корзины. Пожалуйста, попробуйте позже.');
    }
  };

  // Функция для обновления итоговой суммы
  const updateCartTotal = () => {
    let total = 0;
    document.querySelectorAll('.cart-item').forEach(item => {
      const priceText = item.querySelector('.cart-item-price').textContent;
      const price = parseFloat(priceText.replace(/[^\d.]/g, '')); // Извлекаем число из строки
      total += price;
    });
    cartTotalPriceElement.textContent = total.toFixed(0);
  };

  // Загрузка корзины
  const loadCart = async () => {
    try {
      // Запрос на получение списка элементов корзины
      const cartResponse = await fetch('https://stroylomay.shop/api/v1/cart', {
        credentials: 'same-origin'
      });
      if (!cartResponse.ok) {
        throw new Error(`Ошибка загрузки корзины: ${cartResponse.statusText}`);
      }
      const cartItems = await cartResponse.json();

      // Очищаем контейнер
      cartItemsContainer.innerHTML = '';

      // Если корзина пуста
      if (!cartItems || cartItems.length === 0) {
        cartItemsContainer.classList.add('hide');
        cartSummaryElement.classList.add('hide');
        cartEmptyElement.classList.remove('hide');
        return;
      }

      // Для каждого элемента корзины загружаем информацию о товаре
      const itemDetailsPromises = cartItems.map(cartItem => fetchItemDetails(cartItem.item_id));
      const itemsDetails = await Promise.all(itemDetailsPromises);

      // Объединяем данные корзины и информацию о товарах
      const cartWithDetails = cartItems.map((cartItem, index) => {
        return { ...cartItem, ...itemsDetails[index] };
      });

      // Добавляем товары в DOM
      cartWithDetails.forEach(item => {
        cartItemsContainer.appendChild(createCartItemCard(item));
      });

      // Отображаем итоговую сумму
      updateCartTotal();
      cartEmptyElement.classList.add('hide');
      cartSummaryElement.classList.remove('hide');

      // Удаляем предыдущие обработчики кликов, если они были
      cartItemsContainer.removeEventListener('click', handleCartContainerClick);

      // Добавляем новый обработчик кликов для контейнера корзины
      cartItemsContainer.addEventListener('click', handleCartContainerClick);
    } catch (error) {
      console.error('Ошибка загрузки корзины:', error);
      cartItemsContainer.innerHTML = `<div class="cart-error">Произошла ошибка при загрузке корзины. Пожалуйста, попробуйте позже.</div>`;
    }
  };

  // Обработчик кликов для контейнера корзины
  const handleCartContainerClick = (e) => {
    // Обработка клика по кнопке удаления
    if (e.target.classList.contains('btn-remove')) {
      e.stopPropagation(); // Предотвращаем всплытие события
      const cartId = e.target.dataset.id;
      const itemId = e.target.dataset.itemId;
      removeFromCart(cartId, itemId);
    }

    // Предотвращаем всплытие событий для ссылок на склад
    if (e.target.closest('.cart-item-warehouse a')) {
      e.stopPropagation();
    }
  };

  // Загружаем корзину
  loadCart();
}

function logout() {
  fetch('stroylomay.shop/api/v1/logout', {
    method: 'POST',
    credentials: 'same-origin'
  })
    .finally(() => {
      // Стираем cookie с JWT
      document.cookie = 'jwt=; Max-Age=0; path=/;';
      // Перенаправляем на страницу входа
      window.location.href = '/login.html';
    });
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

  // Инициализация страниц каталога, товара, склада и корзины
  if (path.endsWith('catalog.html')) {
    initCatalogPage();
  } else if (path.endsWith('item.html')) {
    initItemPage();
  } else if (path.endsWith('wirehouse.html')) {
    initWirehousePage();
  } else if (path.endsWith('cart.html')) {
    initCartPage();
  }

  // Если открыта страница аккаунта, проверяем наличие JWT
  if (path.endsWith('account.html')) {
    if (!isLoggedIn()) {
      redirectToLogin();
    } else {
      initAccountPage().then(() => {
        initAccountEdit();
      });
    }
  }

  const logoutBtn = document.getElementById('logout-btn');
  if (logoutBtn) logoutBtn.addEventListener('click', logout);
});
