// scripts.js

// --- Utility Functions ---
function getQueryParam(param) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(param);
}

function truncateText(text, maxLength) {
  if (!text) return '';
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
}

// --- Load Items for Main Page ---
function loadItems() {
  const itemsContainer = document.getElementById('products-wrap');
  if (!itemsContainer) return;

  fetch('https://stroylomay.shop/api/v1/items?page=1')
    .then(response => response.json())
    .then(data => {
      data.items.forEach(item => {
        const card = createProductCard(item);
        itemsContainer.appendChild(card);
      });
    })
    .catch(error => console.error('Ошибка при загрузке товаров:', error));
}

// --- Create Product Card ---
function createProductCard(product) {
  // Оборачиваем карточку в ссылку для перехода на детальную страницу
  const link = document.createElement('a');
  link.href = `item.html?id=${product.id}`;
  link.className = 'product-link';

  const card = document.createElement('div');
  card.className = 'product-card';

  // Image Section
  const imageSection = document.createElement('div');
  imageSection.className = 'image-section';
  const image = document.createElement('img');
  image.className = 'product-image';
  image.src = 'img/' + product.img_url;
  image.alt = product.name;
  imageSection.appendChild(image);

  // Title Section
  const titleSection = document.createElement('div');
  titleSection.className = 'title-section';
  const title = document.createElement('h3');
  title.className = 'product-title';
  title.textContent = product.name;
  titleSection.appendChild(title);

  // Price Section
  const priceSection = document.createElement('div');
  priceSection.className = 'price-section';
  const price = document.createElement('p');
  price.className = 'product-price';
  price.textContent = product.price ? `${product.price} ₽` : '';
  priceSection.appendChild(price);

  // Description Section
  const descriptionSection = document.createElement('div');
  descriptionSection.className = 'description-section';
  const description = document.createElement('p');
  description.className = 'product-description';
  description.textContent = truncateText(product.description, 100);
  descriptionSection.appendChild(description);

  // Action Section (Cart Button)
  const actionSection = document.createElement('div');
  actionSection.className = 'action-section';
  const cartButton = document.createElement('button');
  cartButton.className = 'cart-button';
  cartButton.textContent = 'Добавить в корзину';

  // Предотвращаем переход по ссылке при клике по кнопке
  cartButton.addEventListener('click', (e) => {
    e.stopPropagation();
    e.preventDefault();
    fetch('https://stroylomay.shop/api/v1/cart', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ item_id: product.id })
    })
      .then(response => {
        if (!response.ok) throw new Error('Ошибка при добавлении в корзину');
        return response.json();
      })
      .then(data => console.log('Товар успешно добавлен в корзину:', data))
      .catch(error => console.error('Ошибка:', error));
  });
  actionSection.appendChild(cartButton);

  // Собираем карточку
  card.appendChild(imageSection);
  card.appendChild(titleSection);
  card.appendChild(priceSection);
  card.appendChild(descriptionSection);
  card.appendChild(actionSection);

  // Оборачиваем карточку в ссылку
  link.appendChild(card);
  return link;
}

function getCookie(name) {
  const cookies = document.cookie.split('; ');
  for (const cookie of cookies) {
    const [key, value] = cookie.split('=');
    if (key === name) {
      return value;
    }
  }
  return null;
}

function requireAuth(redirectUrl) {
  if (!getCookie('jwt')) {
    window.location.replace(redirectUrl);
  }
}

// Немедленно вызываемая функция для инициализации логики авторизации
(function () {
  // Если пользователь находится на странице account.html, проверяем наличие jwt
  if (window.location.pathname.endsWith('/account.html')) {
    requireAuth('/login.html');
  }

  // Если на странице присутствует элемент с id="accountIcon", привязываем к нему обработчик клика
  const accountIcon = document.getElementById('accountIcon');
  if (accountIcon) {
    accountIcon.addEventListener('click', function (e) {
      // Если jwt отсутствует, предотвращаем переход по ссылке и делаем редирект
      if (!getCookie('jwt')) {
        e.preventDefault();
        window.location.replace('/login.html');
      }
    });
  }
})();

function login() {
  const authForm = document.getElementById("auth-form");

  authForm.addEventListener("submit", async (event) => {
    event.preventDefault(); // Отменяем стандартную отправку формы

    // Получаем значения из полей
    const login = document.getElementById("login").value.trim();
    const password = document.getElementById("password").value;

    const credentials = { login, password };

    try {
      // Отправляем запрос к API методом POST
      const response = await fetch("https://stroylomay.shop/api/v1/login", {
        method: "POST", // Изменили метод на POST
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(credentials)
      });

      if (!response.ok) {
        throw new Error("Ошибка авторизации: " + response.statusText);
      }

      const data = await response.json();

      if (data.token) {
        // Сохраняем токен в cookies
        document.cookie = `jwt=${data.token}; path=/;`;

        // Редирект на главную страницу
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

// --- Initialization ---
document.addEventListener('DOMContentLoaded', () => {
  loadItems();
  login();
});
