const { GoogleGenerativeAI } = require("@google/generai");

module.exports = async (req, res) => {
  // 1. Configuración de la IA con la versión correcta (v1alpha)
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY, {
    apiVersion: "v1alpha",
  });

  // 2. Selección del modelo compatible
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  if (req.method === "POST") {
    try {
      const { prompt } = req.body;

      // 3. Generación del contenido
      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      // 4. Enviamos la respuesta al frontend
      res.status(200).json({ 
        candidates: [{ 
          content: { parts: [{ text: text }] } 
        }] 
      });
    } catch (error) {
      console.error("Error en la API:", error);
      res.status(500).json({ error: error.message });
    }
  } else {
    // Si intentan entrar por navegador (GET) les damos un error amigable
    res.status(405).json({ error: "Método no permitido. Usa POST desde el formulario." });
  }
};