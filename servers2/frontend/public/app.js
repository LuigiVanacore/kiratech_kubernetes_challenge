document.addEventListener('DOMContentLoaded', () => {
  const backendUrl = '/api'; // The frontend server will proxy requests to the backend server
  const messageContentInput = document.getElementById('message-content');
  const sendMessageButton = document.getElementById('send-message-button');
  const getMessagesButton = document.getElementById('get-messages-button');
  const messagesList = document.getElementById('messages-list');
  const errorMessage = document.getElementById('error-message');

  // Send message to backend
  sendMessageButton.addEventListener('click', () => {
    const name = messageContentInput.value;

    fetch(`${backendUrl}/items`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ name }),
    })
      .then(response => response.json())
      .then(data => {
        if (data.message) {
          errorMessage.textContent = data.message;
        } else {
          errorMessage.textContent = '';
          messageContentInput.value = '';
        }
      })
      .catch(error => {
        errorMessage.textContent = 'Error sending message';
      });
  });

  // Get messages from backend
  getMessagesButton.addEventListener('click', () => {
    fetch(`${backendUrl}/items`)
      .then(response => response.json())
      .then(data => {
        if (data.message) {
          errorMessage.textContent = data.message;
        } else {
          messagesList.innerHTML = '';
          data.forEach(item => {
            const li = document.createElement('li');
            li.textContent = item.name;
            messagesList.appendChild(li);
          });
          errorMessage.textContent = '';
        }
      })
      .catch(error => {
        errorMessage.textContent = 'Error fetching messages';
      });
  });
});
