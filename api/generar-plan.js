const { GoogleGenerativeAI } = require("@google/generative-ai");

module.exports = async (req, res) => {
  // 1. Configurar CORS para permitir que tu frontend hable con el backend
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  // Responder rápido a las peticiones de control de navegadores
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // 2. Solo permitir POST
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Método no permitido. Usa POST." });
  }

  try {
    const { prompt } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: "Falta el prompt en el cuerpo de la petición." });
    }

    // 3. Inicializar la IA con tu API Key de Vercel
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    
    // Usamos el modelo más estable para la versión v1beta
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    // 4. Generar el contenido
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // 5. Devolver el formato exacto que tu index.html espera
    res.status(200).json({
      candidates: [
        {
          content: {
            parts: [{ text: text }]
          }
        }
      ]
    });

  } catch (error) {
    console.error("Error crítico en la API:", error);
    // Enviamos JSON siempre, para evitar el error de "Unexpected token A"
    res.status(500).json({ 
      error: "Error interno del servidor", 
      message: error.message 
    });
  }
};