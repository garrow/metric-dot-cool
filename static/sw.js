// // Adapted from: https://github.com/mdn/sw-test/blob/gh-pages/sw.js & https://codeburst.io/how-to-make-an-elm-app-progressive-d2e17d2f6fea
//
// self.addEventListener('install', function (e) {
//   e.waitUntil(
//     caches.open('metric-cool').then(function (cache) {
//       return cache.addAll([
//         '/',
//         '/index.html',
//         '/index.js',
//         '/metric-dot-cool-square.png'
//       ]);
//     })
//   );
// });
//
// self.addEventListener('fetch', function (event) {
//   // console.log('Service Worker Intercept: ' + event.request.url);
//
//   event.respondWith(
//     caches.match(event.request).then(function (response) {
//
//       // console.log('Service Worker Serve: ' + event.request.url);
//
//       return response || fetch(event.request);
//
//     })
//   );
// });
//
//
