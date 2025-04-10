// scripts.js

document.addEventListener('DOMContentLoaded', () => {
  // Определяем текущую страницу по URL
  const path = window.location.pathname;
  if (path.endsWith('catalog.html')) {
    initCatalogPage();
  } else if (path.endsWith('item.html')) {
    initItemPage();
  } else if (path.endsWith('wirehouse.html')) {
    initWirehousePage();
  }
});

function initCatalogPage() {
  const itemsContainer = document.getElementById('catalog-items');
  let currentPage = 1;
  let totalPages = null;
  let isLoading = false;

  // Функция создания карточки товара
  function createProductCard(item) {
    const card = document.createElement('div');
    card.className = 'card';

    // Кликабельная область карточки (переход на item.html)
    const link = document.createElement('a');
    link.href = `item.html?id=${item.id}`;
    link.className = 'card-content';

    // Блок с изображением
    const imageWrapper = document.createElement('div');
    imageWrapper.className = 'card-image';
    const img = document.createElement('img');
    img.src = 'https://stroylomay.shop/img/' + item.img_url;
    img.alt = item.name;
    img.loading = 'lazy';
    imageWrapper.appendChild(img);
    link.appendChild(imageWrapper);

    // Информационный блок с данными
    const infoBlock = document.createElement('div');
    infoBlock.className = 'card-info';

    // Верхняя часть – заголовок и описание
    const textBlock = document.createElement('div');
    textBlock.className = 'card-text';
    const title = document.createElement('h3');
    title.textContent = item.name;
    title.className = 'card-title';
    textBlock.appendChild(title);
    let description = item.description || '';
    if (description.length > 60) {
      description = description.substring(0, 60) + '...';
    }
    const descElem = document.createElement('p');
    descElem.textContent = description;
    descElem.className = 'card-desc';
    textBlock.appendChild(descElem);
    infoBlock.appendChild(textBlock);

    // Нижняя часть – цена и склад (прижатые к низу)
    const bottomBlock = document.createElement('div');
    bottomBlock.className = 'card-bottom';
    const priceElem = document.createElement('p');
    priceElem.textContent = item.price + ' ₽/День';
    priceElem.className = 'card-price';
    bottomBlock.appendChild(priceElem);
    const warehouseElem = document.createElement('p');
    warehouseElem.className = 'card-warehouse';
    warehouseElem.innerHTML =
      'Склад: <a href="wirehouse.html?id=' +
      (item.warehouse_id || '') +
      '">' +
      item.warehouse_name +
      '</a>';
    bottomBlock.appendChild(warehouseElem);
    infoBlock.appendChild(bottomBlock);

    link.appendChild(infoBlock);
    card.appendChild(link);

    // Отдельный блок для кнопки "Добавить в корзину"
    const buttonBlock = document.createElement('div');
    buttonBlock.className = 'card-button';
    const addBtn = document.createElement('button');
    addBtn.textContent = 'Добавить в корзину';
    addBtn.className = 'add-to-cart';
    addBtn.setAttribute('data-id', item.id);
    buttonBlock.appendChild(addBtn);
    card.appendChild(buttonBlock);

    return card;
  }

  function appendItems(items) {
    items.forEach(item => {
      const card = createProductCard(item);
      itemsContainer.appendChild(card);
    });
  }

  function loadItems(page) {
    if (isLoading) return;
    isLoading = true;
    fetch(`https://stroylomay.shop/api/v1/items?page=${page}`)
      .then(response => response.json())
      .then(data => {
        const items = data.items || data;
        if (items && items.length > 0) {
          appendItems(items);
          currentPage = page;
          if (data.total_pages) {
            totalPages = data.total_pages;
          }
        }
        if (!items || items.length === 0) {
          totalPages = currentPage;
        }
      })
      .catch(err => console.error('Ошибка загрузки товаров:', err))
      .finally(() => {
        isLoading = false;
      });
  }

  loadItems(1);
  window.addEventListener('scroll', () => {
    const nearBottom =
      window.innerHeight + window.scrollY >= document.body.offsetHeight - 100;
    if (nearBottom && !isLoading) {
      if (totalPages === null || currentPage < totalPages) {
        loadItems(currentPage + 1);
      }
    }
  });

  itemsContainer.addEventListener('click', (e) => {
    if (e.target.classList.contains('add-to-cart')) {
      e.preventDefault();
      const itemId = e.target.getAttribute('data-id');
      handleAddToCart(itemId);
    }
  });
}

function initItemPage() {
  const params = new URLSearchParams(window.location.search);
  const itemId = params.get('id');
  if (!itemId) return;
  fetch(`https://stroylomay.shop/api/v1/items?id=${itemId}`)
    .then(response => response.json())
    .then(data => {
      document.getElementById('item-name').textContent = data.name;
      document.getElementById('item-desc').textContent = data.description;
      document.getElementById('item-price').textContent = data.price;
      document.getElementById('item-penalty').textContent = data.late_penalty;
      document.getElementById('item-active').textContent = data.active ? 'Да' : 'Нет';
      const imgElem = document.getElementById('item-image');
      if (imgElem) {
        imgElem.src = 'https://stroylomay.shop/img/' + data.img_url;
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
      document.title = data.name + " – Строй Ломай";
    })
    .catch(err => console.error('Ошибка загрузки товара:', err));
}

function initWirehousePage() {
  const params = new URLSearchParams(window.location.search);
  const whId = params.get('id');
  if (!whId) return;
  fetch(`https://stroylomay.shop/api/v1/wirehouses?id=${whId}`)
    .then(response => response.json())
    .then(data => {
      document.getElementById('wh-name').textContent = data.name;
      document.getElementById('wh-phone').textContent = data.phone;
      document.getElementById('wh-email').textContent = data.email;
      document.getElementById('wh-address').textContent = data.address;
      document.getElementById('wh-active').textContent = data.active ? 'Да' : 'Нет';
      document.title = data.name + " – Строй Ломай";
    })
    .catch(err => console.error('Ошибка загрузки склада:', err));
}

function isLoggedIn() {
  return document.cookie.split(';').some(item => item.trim().startsWith('jwt='));
}

function handleAddToCart(itemId) {
  if (!isLoggedIn()) {
    alert('Пожалуйста, авторизуйтесь для добавления товара в корзину');
    return;
  }
  fetch(`https://stroylomay.shop/api/v1/cart?id=${itemId}`, { method: 'POST', credentials: 'same-origin' })
    .then(response => {
      if (response.ok) {
        const cartIcon = document.querySelector('.cart-icon');
        if (cartIcon) {
          cartIcon.classList.add('shake');
          setTimeout(() => cartIcon.classList.remove('shake'), 500);
        }
      } else {
        console.error('Не удалось добавить в корзину. Статус:', response.status);
      }
    })
    .catch(err => console.error('Ошибка при добавлении в корзину:', err));
}

document.addEventListener('DOMContentLoaded', () => {
  const accountLinks = document.querySelectorAll('a[href="/account.html"]');
  accountLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      if (document.cookie.indexOf("jwt=") === -1) {
        e.preventDefault();
        window.location.replace("/login.html?redirect=" + encodeURIComponent(window.location.href));
      }
    });
  });
});


function login() {
  const authForm = document.getElementById("auth-form");

  authForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const login = document.getElementById("login").value.trim();
    const password = document.getElementById("password").value;

    const credentials = { login, password };

    try {
      const response = await fetch("https://stroylomay.shop/api/v1/login", {
        method: "POST",
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