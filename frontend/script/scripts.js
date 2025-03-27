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

// --- Account Link Setup ---
function setupAccountLink() {
  const accountLink = document.getElementById('account-link');
  if (!accountLink) return;
  
  accountLink.addEventListener('click', (event) => {
    event.preventDefault();
    const tokenCookie = document.cookie.split('; ').find(row => row.startsWith('jwt='));
    if (!tokenCookie) {
      window.location.href = 'login.html';
      return;
    }
    const jwt = tokenCookie.split('=')[1];
    fetch('/api/v1/account', { headers: { 'Authorization': 'Bearer ' + jwt } })
      .then(response => {
        if (response.status === 401) {
          return response.text().then(text => {
            if (text.includes('token missing') || text.includes('invalid token')) {
              window.location.href = 'login.html';
            }
          });
        } else if (response.ok) {
          window.location.href = 'account.html';
        }
      })
      .catch(error => {
        console.error('Ошибка проверки токена:', error);
        window.location.href = 'login.html';
      });
  });
}

// --- Login Form Setup ---
function setupLoginForm() {
  const loginForm = document.getElementById('login-form');
  if (!loginForm) return;
  
  const loginMessage = document.getElementById('login-message');
  loginForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const login = document.getElementById('login').value;
    const password = document.getElementById('password').value;
    
    fetch('https://stroylomay.shop/api/v1/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ login, password })
    })
      .then(response => {
        if (response.status === 200) return response.json();
        else throw new Error('Неверный логин или пароль');
      })
      .then(data => {
        document.cookie = "jwt=" + data.token + "; path=/";
        window.location.href = 'index.html';
      })
      .catch(error => {
        if (loginMessage) {
          loginMessage.textContent = error.message;
          loginMessage.style.color = 'red';
        }
      });
  });
}

// --- Register Form Setup ---
function setupRegisterForm() {
  const registerForm = document.getElementById('register-form');
  if (!registerForm) return;
  
  const registerMessage = document.getElementById('register-message');
  registerForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const login = document.getElementById('login').value;
    const password = document.getElementById('password').value;
    
    fetch('https://stroylomay.shop/api/v1/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ login, password })
    })
      .then(response => {
        if (response.status === 201) return response.json();
        else throw new Error('Ошибка регистрации. Проверьте введенные данные.');
      })
      .then(() => window.location.href = 'login.html')
      .catch(error => {
        if (registerMessage) {
          registerMessage.textContent = error.message;
          registerMessage.style.color = 'red';
        }
      });
  });
}

// --- Load Items for Main Page ---
function loadItems() {
  const itemsContainer = document.getElementById('products-wrap');
  if (!itemsContainer) return;
  
  fetch('https://stroylomay.shop/api/v1/items?page=1')
    .then(response => response.json())
    .then(data => {
      data.items.forEach(item => {
        console.log('Создаем карточку для:', item);
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

// --- Load Product Details ---
function loadItemDetails() {
  const itemDetailsDiv = document.getElementById('item-details');
  if (!itemDetailsDiv) return;
  
  const itemId = getQueryParam('id');
  if (!itemId) {
    itemDetailsDiv.textContent = 'ID товара не указан.';
    return;
  }
  
  fetch('/api/v1/items?id=' + itemId)
    .then(response => response.json())
    .then(item => {
      itemDetailsDiv.innerHTML = `
        <h2>${item.name}</h2>
        <p>${item.description}</p>
        <p>Цена: ${item.price}</p>
        <p>Склад: ${item.warehouse_id}</p>
        <p>Активность: ${item.active ? 'Да' : 'Нет'}</p>
        <p>Качество: ${item.quality}</p>
        <p>Штраф за опоздание: ${item.late_penalty}</p>
        <p>Изображение: <img src="${item.img_url}" alt="${item.name}" style="max-width:100%;"></p>
      `;
    })
    .catch(error => {
      itemDetailsDiv.textContent = 'Ошибка при загрузке информации о товаре.';
      console.error('Ошибка:', error);
    });
}

// --- Load Account Information ---
function loadAccountInfo() {
  const userInfoDiv = document.getElementById('user-info');
  if (!userInfoDiv) return;
  
  const tokenCookie = document.cookie.split('; ').find(row => row.startsWith('jwt='));
  if (!tokenCookie) {
    window.location.href = 'login.html';
    return;
  }
  
  const jwt = tokenCookie.split('=')[1];
  fetch('/api/v1/account', { headers: { 'Authorization': 'Bearer ' + jwt } })
    .then(response => {
      if (response.status === 401) {
        return response.text().then(text => {
          if (text.includes('token missing') || text.includes('invalid token')) {
            window.location.href = 'login.html';
          }
        });
      }
      return response.json();
    })
    .then(data => {
      if (data) {
        userInfoDiv.innerHTML = `
          <p><strong>ID:</strong> ${data.id}</p>
          <p><strong>Логин:</strong> ${data.login || 'не указан'}</p>
          <p><strong>Имя:</strong> ${data.firstname || 'не указано'}</p>
          <p><strong>Фамилия:</strong> ${data.lastname || 'не указано'}</p>
          <p><strong>Телефон:</strong> ${data.phone || 'не указан'}</p>
          <p><strong>Email:</strong> ${data.email || 'не указан'}</p>
          <p><strong>Адрес:</strong> ${data.address || 'не указан'}</p>
          <p><strong>Паспорт:</strong> ${data.passport || 'не указан'}</p>
        `;
      }
    })
    .catch(error => {
      console.error('Ошибка при загрузке аккаунта:', error);
      window.location.href = 'login.html';
    });
}

// --- Logout Setup ---
function setupLogout() {
  const logoutBtn = document.getElementById('logout-btn');
  if (!logoutBtn) return;
  
  logoutBtn.addEventListener('click', () => {
    const tokenCookie = document.cookie.split('; ').find(row => row.startsWith('jwt='));
    if (!tokenCookie) {
      window.location.href = 'login.html';
      return;
    }
    const jwt = tokenCookie.split('=')[1];
    fetch('/api/v1/logout', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + jwt
      }
    })
      .then(response => {
        if (response.ok) {
          document.cookie = "jwt=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
          window.location.href = 'login.html';
        } else {
          console.error('Ошибка при выходе.');
        }
      })
      .catch(error => console.error('Ошибка при выполнении запроса на выход:', error));
  });
}

// --- Initialization ---
document.addEventListener('DOMContentLoaded', () => {
  setupAccountLink();
  setupLoginForm();
  setupRegisterForm();
  loadItems();
  loadItemDetails();
  loadAccountInfo();
  setupLogout();
});
