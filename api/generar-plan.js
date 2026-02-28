export default async function handler(req, res) {
  const API_KEY = process.env.GEMINI_API_KEY; 
  const { prompt } = req.body;

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { maxOutputTokens: 4000 }
        })
      }
    );

    const data = await response.json();
    
    if (!response.ok) {
        return res.status(response.status).json(data);
    }

    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: "Error en el servidor de Node.js" });
  }
}