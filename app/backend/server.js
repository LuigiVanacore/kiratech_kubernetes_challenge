const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 8080;

app.use(bodyParser.json());
app.use(cors());

const mongoUrl = process.env.MONGO_URL;

function connectWithRetry() {
  return mongoose.connect(mongoUrl, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  }).then(() => {
    console.log('Connessione MongoDB');
  }).catch((error) => {
    console.error('Errore connessione MongoDB:', error.message);
    console.log('Retry 5 secondi...');
    setTimeout(connectWithRetry, 5000); 
  });
}

connectWithRetry();

const db = mongoose.connection;
db.on('error', (error) => {
  console.error('Errore connessione:', error.message);
});

const itemSchema = new mongoose.Schema({
  name: String,
});

const Item = mongoose.model('Item', itemSchema);

app.get('/api/items', async (req, res) => {
  try {
    const items = await Item.find();
    res.json(items);
  } catch (error) {
    console.error('Errore recupero messaggi:', error.message);
    res.status(500).json({ message: 'Errore recupero messaggi', error: error.message });
  }
});

app.post('/api/items', async (req, res) => {
  try {
    const newItem = new Item(req.body);
    await newItem.save();
    res.json(newItem);
  } catch (error) {
    console.error('Errore salvataggio messaggio:', error.message);
    res.status(500).json({ message: 'Errore salvataggio messaggio', error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Backend server http://localhost:${port}`);
});
