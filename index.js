const express = require('express');
const multer = require('multer');
const nodemailer = require('nodemailer');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Multer setup for file uploads
const upload = multer({ storage: multer.memoryStorage() });

// POST endpoint to send an email with the QR code attachment
app.post('/send-email', upload.single('image'), async (req, res) => {
  const { to, subject, text } = req.body;

  // Validate required fields
  if (!to || !subject || !text) {
    return res.status(400).send('Missing required fields: to, subject, or text');
  }

  if (!req.file) {
    return res.status(400).send('No file uploaded');
  }

  // Configure nodemailer transporter
  const transporter = nodemailer.createTransport({
    service: 'gmail', // Change if using a different email service
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
    tls: {
      rejectUnauthorized: false, // Allows self-signed certificates
    },
  });

  // Define email options
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to,
    subject,
    text,
    attachments: [
      {
        filename: 'qr_code.png',
        content: req.file.buffer,
      },
    ],
  };

  // Send the email
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent:', info.response);
    res.status(200).send('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).send('Failed to send email: ' + error.message);
  }
});

// Health check route
app.get('/health', (req, res) => {
  res.status(200).send('Server is running');
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
