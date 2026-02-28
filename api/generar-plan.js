const { GoogleGenerativeAI } = require("@google/generative-ai");

module.exports = async (req, res) => {
  
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const { prompt } = req.body;
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    
    
    const model = genAI.getGenerativeModel({ model: "gemini-1.0-pro" });

    const result = await model.generateContent(prompt);
    const response = await result.response;
    
    res.status(200).json({
      candidates: [{ content: { parts: [{ text: response.text() }] } }]
    });
  } catch (error) {
    console.error("ERROR REAL:", error);
    return res.status(500).json({ error: error.message });
}
};