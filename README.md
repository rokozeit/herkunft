# Herkunft

Who is the manufacturer of the milk, cheese or sausage, for example? Was the cheaper product produced by the same manufacturer as a well-known brand product?

In order to identify the producer of products of animal origin, the EU has introduced the so-called health mark. It is an oval symbol that includes, among other things, the country of origin and the approval number of the manufacturing company.

<img src="assets/image.png" alt="health mark example" width="200" height="auto">

This app that let's you quickly identify manufacturer by selecting the country and the approval number. Currently, the countries - Germany (DE), Austria (AT), Switzerland (CH), Italy (IT) and France (FR) are available in the app. Since the data are extracted from the individual sides and I do not have an agreement with the authorities maintaining these data, the data is not included in this app. Some sample scripts to extract these data can be found at [this project](https://github.com/rokozeit/herkunft_daten). 

*__Just because a product comes from the same manufacturer does not mean it is the same product.__*

What is working at the moment is:

- Android build: `flutter build apk`
- Windows build: `flutter build windows`