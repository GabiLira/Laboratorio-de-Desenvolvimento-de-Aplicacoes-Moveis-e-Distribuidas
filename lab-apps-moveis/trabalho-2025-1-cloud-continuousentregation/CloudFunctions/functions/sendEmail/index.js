const axios = require("axios");
const nodemailer = require('nodemailer');


exports.sendEmail = async (req, res) => {
    const { to, subject, text } = req.body;

    if (!to || !subject || !text) {
        return res.status(400).send("Parâmetros 'to', 'subject' e 'text' são obrigatórios.");
    }

    try{
        const mailOptions = {
            from: 'matheus35ro@gmail.com',
            to: `${to}`,
            subject: `${subject}`,
            text: `${text}`,
        };

        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'matheus35ro@gmail.com',
                pass: 'PASSWORD_DO_EMAIL', // Substitua pela senha do seu e-mail
            },
        });

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                return console.error('Erro ao enviar e-mail:', error);
            }
            console.log('E-mail enviado com sucesso:', info.response);
        });
        res.status(200).send("Email enviado");
    } catch (error) {
        console.error('Erro ao enviar e-mail:', error);
        res.status(500).send("Erro ao enviar email");
    }
}
