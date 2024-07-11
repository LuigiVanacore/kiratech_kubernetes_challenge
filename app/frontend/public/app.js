document.addEventListener('DOMContentLoaded', () => {
    const itemsList = document.getElementById('items-list');
    const itemForm = document.getElementById('item-form');
    const itemNameInput = document.getElementById('item-name');
  
    // Fetch items from backend
    fetch('http://backend:8080/api/items')
      .then(response => response.json())
      .then(data => {
        data.forEach(item => {
          const li = document.createElement('li');
          li.textContent = item.name;
          itemsList.appendChild(li);
        });
      });
  
    // Add new item
    itemForm.addEventListener('submit', (event) => {
      event.preventDefault();
      const newItemName = itemNameInput.value;
  
      fetch('http://backend:8080/api/items', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name: newItemName }),
      })
        .then(response => response.json())
        .then(newItem => {
          const li = document.createElement('li');
          li.textContent = newItem.name;
          itemsList.appendChild(li);
          itemNameInput.value = '';
        });
    });
  });
  