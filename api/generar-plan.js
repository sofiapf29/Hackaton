export default async function handler(req, res) {

  const API_KEY = process.env.GEMINI_API_KEY; 
  const { prompt } = req.body;


  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${API_KEY}`;

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ],
        generationConfig: {
          maxOutputTokens: 4000,
          temperature: 0.7 
        }
      })
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    res.status(200).json(data);
  } catch (error) {
    console.error("Error en el servidor:", error);
    res.status(500).json({ error: "Error de conexión con el servidor de Node.js" });
  }
}