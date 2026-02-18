function recognizeImageText(imageBase64, callback) {
  Tesseract.recognize(
    imageBase64,
    'eng',
    { logger: m => console.log(m) }
  ).then(({ data: { text } }) => {
    callback(text);
  });
}
