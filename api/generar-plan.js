module.exports = async (req, res) => {
  // Solo permitimos peticiones POST
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Método no permitido" });
  }

  const { prompt } = req.body;
  const apiKey = process.env.GEMINI_API_KEY;

  // Usamos la URL directa con la versión v1beta que es la más estable para este modelo
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }]
      }),
    });

    const data = await response.json();

    // Verificamos si Google respondió correctamente
    if (data.candidates && data.candidates[0]) {
      // Devolvemos la data en el formato exacto que tu index.html ya sabe leer
      res.status(200).json(data);
    } else {
      res.status(500).json({ error: "La IA no devolvió resultados", detalles: data });
    }
  } catch (error) {
    // Si algo falla, enviamos un JSON real para que no salga el error de "Token A"
    res.status(500).json({ error: "Error de servidor", message: error.message });
  }
};