const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'El nombre es obligatorio'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'La descripción es obligatoria'],
    trim: true,
  },
  price: {
    type: Number,
    required: [true, 'El precio es obligatorio'],
    min: [0, 'El precio no puede ser negativo'],
  },
  category: {
    type: String,
    required: [true, 'La categoría es obligatoria'],
    enum: ['consolas', 'videojuegos', 'accesorios'], // <- actualiza esto si tienes más
  },
  quantity: {
    type: Number,
    required: [true, 'La cantidad es obligatoria'],
    min: [0, 'La cantidad no puede ser negativa'],
  },
  imageUrl: {
    type: String,
    required: [true, 'La imagen es obligatoria'],
  },
}, { timestamps: true });

module.exports = mongoose.model('Product', ProductSchema);
