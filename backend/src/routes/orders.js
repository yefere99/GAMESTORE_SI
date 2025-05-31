const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Product = require('../models/Product');

// Crear orden
router.post('/', async (req, res) => {
  try {
    const {
      items,
      total,
      name,
      address,
      email,
      phone,
      paymentMethod
    } = req.body;

    // 🧪 Log inicial
    console.log("📦 Orden recibida del frontend:");
    console.log({ items, total, name, address, email, phone, paymentMethod });

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'No hay productos en la orden.' });
    }

    // Validación y descuento de stock
    for (const item of items) {
      try {
        if (!item.productId || !item.quantity || item.quantity <= 0) {
          return res.status(400).json({ error: `Datos inválidos para producto: ${JSON.stringify(item)}` });
        }

        const product = await Product.findById(item.productId);

        if (!product) {
          return res.status(400).json({ error: `Producto no encontrado: ${item.productId}` });
        }

        if (product.quantity < item.quantity) {
          return res.status(400).json({ error: `Stock insuficiente para ${item.name}` });
        }

        product.quantity -= item.quantity;
        await product.save();
      } catch (innerError) {
        console.error('❌ Error procesando producto:', item, innerError);
        return res.status(500).json({ error: 'Error interno al verificar productos.' });
      }
    }

    // 🧾 Generar ID de orden
    const orderId = 'ORD' + Date.now();

    const newOrder = new Order({
      orderId,
      name,
      email,
      phone,
      address,
      paymentMethod,
      total,
      items
    });

    console.log('✅ Lista para guardar en MongoDB:', newOrder);

    await newOrder.save();

    res.status(201).json({
      message: 'Orden creada exitosamente',
      orderId,
      order: newOrder
    });

  } catch (error) {
    console.error('❌ Error al crear la orden:', error);
    res.status(500).json({ error: 'Error del servidor al registrar la orden' });
  }
});

// Obtener todas las órdenes
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    console.error('❌ Error al obtener órdenes:', error);
    res.status(500).json({ error: 'No se pudieron obtener las órdenes' });
  }
});
// Marcar orden como notificada
// Marcar orden como notificada
router.patch('/:id/notify', async (req, res) => {
  try {
    const { id } = req.params;

    // Validar el formato del ID (opcional si no usas MongoDB ObjectId aquí)
    if (!id || typeof id !== 'string') {
      return res.status(400).json({ error: 'ID de orden inválido' });
    }

    // Buscar y actualizar la orden por su orderId
    const order = await Order.findOneAndUpdate(
      { orderId: id },
      { $set: { notified: true } },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ error: `No se encontró la orden con ID ${id}` });
    }

    return res.status(200).json({
      message: `Orden ${id} marcada como notificada`,
      orderId: order.orderId,
      notified: order.notified,
      updatedAt: order.updatedAt,
    });
  } catch (error) {
    console.error('❌ Error al marcar como notificada:', error);
    return res.status(500).json({ error: 'Error del servidor al actualizar la orden' });
  }
});


module.exports = router;
