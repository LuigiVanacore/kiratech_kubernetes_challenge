const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 8080;

app.use(bodyParser.json());
app.use(cors());

const mongoUrl = process.env.MONGO_URL;

// MongoDB connection
mongoose.connect(mongoUrl, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).catch(error => {
  console.error('Error connecting to MongoDB:', error.message);
});

const db = mongoose.connection;
db.on('error', (error) => {
  console.error('Connection error:', error.message);
});
db.once('open', () => {
  console.log('Connected to MongoDB');
});

// Define a schema and model
const itemSchema = new mongoose.Schema({
  name: String,
});

const Item = mongoose.model('Item', itemSchema);

// Define routes
app.get('/api/items', async (req, res) => {
  try {
    const items = await Item.find();
    res.json(items);
  } catch (error) {
    console.error('Error fetching items:', error.message);
    res.status(500).json({ message: 'Error fetching items', error: error.message });
  }
});

app.post('/api/items', async (req, res) => {
  try {
    const newItem = new Item(req.body);
    await newItem.save();
    res.json(newItem);
  } catch (error) {
    console.error('Error adding item:', error.message);
    res.status(500).json({ message: 'Error adding item', error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Backend server running at http://localhost:${port}`);
});
