const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  orderId: String,
  name: String,
  email: String,
  phone: String,
  address: String,
  paymentMethod: String,
  total: Number,
  notified: { type: Boolean, default: false }, 
  items: [
    {
      productId: mongoose.Schema.Types.ObjectId,
      name: String,
      quantity: Number,
      price: Number,
    }
  ],
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
