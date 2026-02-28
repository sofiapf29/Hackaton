const { GoogleGenerativeAI } = require("@google/generative-ai");

module.exports = async (req, res) => {
  if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

  try {
    const { prompt } = req.body;
    // Usamos la versión de la librería que instalamos arriba
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const result = await model.generateContent(prompt);
    const response = await result.response;
    
    // El formato que tu index.html espera
    const text = response.text();
    res.status(200).json({
      candidates: [{ content: { parts: [{ text: text }] } }]
    });
  } catch (error) {
    // Esto evita que salga el error 500 genérico y nos da pistas
    res.status(500).json({ error: error.message });
  }
};