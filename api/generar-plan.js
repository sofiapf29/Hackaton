const { GoogleGenAI } = require("@google/genai");

module.exports = async (req, res) => {

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  try {

    if (!process.env.GEMINI_API_KEY) {
      throw new Error("API KEY no definida");
    }

    const { prompt } = req.body;

    if (!prompt) {
      throw new Error("Prompt vacío");
    }

    const ai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY
    });

    const response = await ai.models.generateContent({
      model: "gemini-2.0-flash",
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }]
        }
      ]
    });

    const text = response.candidates[0].content.parts[0].text;

    return res.status(200).json({ text });

  } catch (error) {
    console.error("ERROR REAL:", error);
    return res.status(500).json({ error: error.message });
  }
};