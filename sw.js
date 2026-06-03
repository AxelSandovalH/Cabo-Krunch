'use strict';

var CACHE_NAME = 'ck-v2';
var PRECACHE   = ['/sistema.html', '/img/logo-icon.jpg', '/img/logo.jpg'];

/* ── Install: precache ── */
self.addEventListener('install', function(e) {
  self.skipWaiting();
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(c) { return c.addAll(PRECACHE); })
      .catch(function() {})
  );
});

/* ── Activate: clean old caches ── */
self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(k) { return k !== CACHE_NAME; })
            .map(function(k)   { return caches.delete(k);  })
      );
    }).then(function() { return clients.claim(); })
  );
});

/* ── Fetch: network-first, cache fallback ── */
self.addEventListener('fetch', function(e) {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request)
      .then(function(resp) {
        if (resp && resp.status === 200) {
          var clone = resp.clone();
          caches.open(CACHE_NAME).then(function(c) { c.put(e.request, clone); });
        }
        return resp;
      })
      .catch(function() { return caches.match(e.request); })
  );
});

/* ── Message: show notification from main thread ── */
self.addEventListener('message', function(e) {
  if (!e.data || e.data.type !== 'SHOW_NOTIFICATION') return;
  e.waitUntil(
    self.registration.showNotification(e.data.title, {
      body:    e.data.body,
      icon:    '/img/logo-icon.jpg',
      badge:   '/img/logo-icon.jpg',
      tag:     e.data.tag || 'ck-notif',
      vibrate: [200, 100, 200],
      data:    { url: '/sistema.html' }
    })
  );
});

/* ── Notification click: focus or open app ── */
self.addEventListener('notificationclick', function(e) {
  e.notification.close();
  var target = (e.notification.data && e.notification.data.url) || '/sistema.html';
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(list) {
      for (var i = 0; i < list.length; i++) {
        var c = list[i];
        if (c.url.includes('sistema') && 'focus' in c) return c.focus();
      }
      return clients.openWindow(target);
    })
  );
});
