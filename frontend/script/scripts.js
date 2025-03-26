// scripts.js

// --- Общие функции ---
function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
  }
  
  function truncateText(text, maxLength) {
    return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
  }
  
  // --- Обработка клика по ссылке "Аккаунт" (присутствует на всех страницах) ---
  function setupAccountLink() {
    const accountLink = document.getElementById('account-link');
    if (accountLink) {
      accountLink.addEventListener('click', function(event) {
        event.preventDefault();
        const tokenCookie = document.cookie.split('; ').find(row => row.startsWith('jwt='));
        if (!tokenCookie) {
          window.location.href = 'login.html';
          return;
        }
        const jwt = tokenCookie.split('=')[1];
        fetch('/api/v1/account', {
          headers: { 'Authorization': 'Bearer ' + jwt }
        })
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
  }
  
  // --- Логика для страницы входа ---
  function setupLoginForm() {
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
      const loginMessage = document.getElementById('login-message');
      loginForm.addEventListener('submit', function(event) {
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
  }
  
  // --- Логика для страницы регистрации ---
  function setupRegisterForm() {
    const registerForm = document.getElementById('register-form');
    if (registerForm) {
      const registerMessage = document.getElementById('register-message');
      registerForm.addEventListener('submit', function(event) {
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
        .then(data => {
          window.location.href = 'login.html';
        })
        .catch(error => {
          if (registerMessage) {
            registerMessage.textContent = error.message;
            registerMessage.style.color = 'red';
          }
        });
      });
    }
  }
  
  // --- Логика для загрузки товаров (главная страница) ---
  function loaditems() {
    const itemsContainer = document.getElementById('products-wrap');
    if (itemsContainer) {
      fetch('https://stroylomay.shop/api/v1/items?page=1')
      .then(response => response.json())
      .then(data => {
        data.items.slice(0, data.count).forEach(item => {
          const card = createProductCard(item);
          itemsContainer.appendChild(card);
        });
      })
      .catch(error => console.error('Ошибка при загрузке товаров:', error));
    }
  }
  
  function createProductCard(product) {
    // Создаем контейнер карточки
    const card = document.createElement('div');
    card.className = 'product-card';

    // Изображение товара
    const image = document.createElement('img');
    image.className = 'product-image';
    image.src = 'img/' + product.img_url; // берется из json поля
    image.alt = product.name;
  
    // Контейнер деталей
    const details = document.createElement('div');
    details.className = 'product-details';
  
    // Название товара
    const title = document.createElement('h3');
    title.className = 'product-title';
    title.textContent = product.name;
  
    // Цена товара
    const price = document.createElement('p');
    price.className = 'product-price';
    price.textContent = product.price ? `$${product.price}` : '';
  
    // Описание товара
    const description = document.createElement('p');
    description.className = 'product-description';
    description.textContent = product.description || '';
  
    // Добавляем заголовок, цену и описание в details
    details.appendChild(title);
    details.appendChild(price);
    details.appendChild(description);
  
    // Контейнер действия (кнопка "Добавить в корзину")
    const action = document.createElement('div');
    action.className = 'product-action';
  
    // Кнопка для добавления в корзину
    const cartButton = document.createElement('button');
    cartButton.className = 'cartButton';
    cartButton.textContent = 'Добавить в корзину';
  
    // Обработчик клика по кнопке
    cartButton.addEventListener('click', () => {
      fetch('https://stroylomay.shop/api/v1/cart', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ item_id: product.id }) // отправка id товара
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Ошибка при добавлении в корзину');
        }
        return response.json();
      })
      .then(data => {
        console.log('Товар успешно добавлен в корзину:', data);
        // Здесь можно добавить уведомление для пользователя об успешном добавлении
      })
      .catch(error => {
        console.error('Ошибка:', error);
        // Здесь можно добавить уведомление для пользователя об ошибке
      });
    });
  
    // Добавляем кнопку в контейнер действия
    action.appendChild(cartButton);
  
    // Собираем карточку: изображение, детали и действие
    card.appendChild(image);
    card.appendChild(details);
    card.appendChild(action);
  
    return card;
  }  
  
  // --- Логика для страницы товара ---
  function loadItemDetails() {
    const itemDetailsDiv = document.getElementById('item-details');
    if (itemDetailsDiv) {
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
  }
  
  // --- Логика для страницы аккаунта ---
  function loadAccountInfo() {
    const userInfoDiv = document.getElementById('user-info');
    if (userInfoDiv) {
      const tokenCookie = document.cookie.split('; ').find(row => row.startsWith('jwt='));
      if (!tokenCookie) {
        window.location.href = 'login.html';
        return;
      }
      const jwt = tokenCookie.split('=')[1];
      fetch('/api/v1/account', {
        headers: { 'Authorization': 'Bearer ' + jwt }
      })
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
  }
  
  function setupLogout() {
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', function() {
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
        .catch(error => {
          console.error('Ошибка при выполнении запроса на выход:', error);
        });
      });
    }
  }
  
  // --- Инициализация ---
  // По окончании загрузки DOM выполняем настройки нужных элементов.
  document.addEventListener('DOMContentLoaded', function() {
    setupAccountLink();
    setupLoginForm();
    setupRegisterForm();
    loaditems();
    loadItemDetails();
    loadAccountInfo();
    setupLogout();
  });
  