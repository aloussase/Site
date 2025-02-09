---
title: Betting on Progressive Web Applications
---


In this post we explore the modern web APIs available that allow PWAs to
bring a native feel and functionality to mobile platforms. We don't
delve into the how's, but instead focus on the what's. If you are
interested in the former, which I hope you are after reading this post,
I highly recommend reading ["Building Progressive Web
Apps"](https://www.amazon.com/Building-Progressive-Web-Apps-Bringing/dp/1491961651/ref=sr_1_1?crid=1WVAY38U14QZW&dib=eyJ2IjoiMSJ9.Xl0BRDNY8X7v0O5h005aroGt-LgoPjkS-E8ALegCLFHO6XRCBeD1mEUQRs_93-tF559BkSdernKTLtv0IlQ_JZqXfyyk1UV6p8XS1CuIfhf5_tQc7BqwmSEw09YrCSbWzVVmZcczdoj3X3bV-AbIxbuGn6VWdkWM7MF3E5vj-LBvKdW5PkiMiYUtHQcI-J9VNL9YWrLWD3inRotQECjGt1_GMKIE4uukxha7B7TIlc0.G4JUCkb3_g5UvCXdkFRG7AAgAIpMEpuCjVlE0doMdP0&dib_tag=se&keywords=building+progressive+web+apps&qid=1729984198&sprefix=building+progressive+w%2Caps%2C1334&sr=8-1).

<span></span><!--more-->

<div>

------------------------------------------------------------------------

</div>

PWAs[1](#footnote-1){#footnote-anchor-1 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"} (Progressive Web
Apps) are applications built using web technologies, but that aim to
mimic the look and functionality of native apps (eg. iOS, Android). How
can a website play the role of a native application? Indeed, native
applications offer things like offline functionality, local data
storage, notifications, content sharing and native widgets that make the
gap between the web and native seem impossible to cross. But what if I
told that it's already been crossed? Let's explore how.

## Offline-first functionality

You are on a plane, or the metro, or a sewer (you get the idea, some
place with limited connectivity). You remember that the cat asked you to
buy more fish, so you open your fancy ToDo app and jot it down, lest you
trigger its world-ending wrath. You don't know it (or maybe you do if
you're a nerd), but the item gets added to the list even though you have
no internet connection. Later, when you do have connection, a background
job will sync the data with the server and everyone will live happily
ever after.

Sounds like a normal mobile experience, right? Contrast it with what
happens on a web application.

You open your ToDo web app ... except, you can't because you have no
internet connection. Instead, you get distracted by a dinosaur asking
you to help it jump over cacti and duck under weird birds.

But fear not! It's 2024 and we developers have wonderful tools to help
you appease your angry cats. They go by the names of
CacheStorage[2](#footnote-2){#footnote-anchor-2 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"} and
BackgroundSync[3](#footnote-3){#footnote-anchor-3 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}.

Before talking about these funky guys though, we need to talk briefly
about service workers[4](#footnote-4){#footnote-anchor-4
.footnote-anchor component-name="FootnoteAnchorToDOM" target="_self"}.
Service workers, at the most basic level, are JavaScript files that your
applications can register to provide enhanced functionality.

```javascript
if ("serviceWorker" in navigator) {
        navigator.serviceWorker
          .register("./sw.js")
          .then((registration) => console.log("service worker registered"))
          .catch((err) => console.error(err));
}
```

A service worker is an asynchronous, event-driven agent that can keep
running even when the user exits the browser window. It effectively
takes control over your site and can do things like intercept fetch
calls and send messages to your site. For a more extensive discussion on
service workers, see the [MDN
docs](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API).
Now that that's out of the way, let's talk CacheStorage.

CacheStorage is web API that lets us cache (what a surprise) network
requests. This means that on initialization, you can cache static assets
so your site loads even if offline, or you can cache fetch calls to be
able to show your users stale data when offline.

```javascript
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(CACHED_URLS);
    })
  );
});
```

Here we're listening to the service worker's install event and caching a
list of URLs that point to static assets like HTML, CSS, and JavaScript.
But caching alone does nothing but occupy space on the user's device. We
need to use it:

```javascript
self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);

  if (CACHED_URLS.some((u) => url.pathname.endsWith(u))) {
    return event.respondWith(
      caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          return response || fetch(event.request);
        });
      })
    );
  }
}
```

There are many caching patterns suitable for different needs. In this
case, we are doing what's called "cache first, then network". Since we
cached our assets during the install event, we expect to find them in
the cache when the browser tries to fetch them. If for some reason
they're not there, we default to the normal network request. This makes
it so that the user can still visit the web app when they have no
internet connectivity.

Moreover, we can also cache fetch requests to third party APIs so that
we can still show *something* to our users when they're offline. For an
example of this, see [this code
snippet](https://github.com/aloussase/fenix-app/blob/master/sw.js).
Overall, CacheStorage is one of the key pieces in bringing an
offline-first experience for users of your PWAs. The other one is
BackgroundSync.

The idea of BackgroundSync is that you can store work that can't be done
right now in some sort of local storage, and later on a service worker
can retry executing it. For example, in a chat messaging app you may
want users to be able to send messages even when offline, with some
visual cue that they can't be sent right now, and do the actual work of
sending them when they regain connectivity. It may look something like
this:

```javascript
self.addEventListener("sync", (event) => {
  if (event.tag === "sync-messages") {
    event.waitUntil(sendOutboxMessages());
  }
});
```

All in all, CacheStorage and BackgroundSync allow us to bring a truly
offline experience to users that can compete toe to toe with that of
native mobile applications. Now your cats will definitely be happy!

## Local data storage

On Android, it is common to run a SQLite database on the users phone to
store some data locally. Maybe cache responses from an API or just do
the whole persistence on the client. In the PWA world, we have
CacheStore for the first use case. For the second one, we have
IndexedDB.

IndexedDB[5](#footnote-5){#footnote-anchor-5 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"} is the web's
solution to client side storage. It's a database that uses indexes to
enable high performance access to data. It can be used as a key-value
store à la [shared
preferences](https://developer.android.com/training/data-storage/shared-preferences),
or as a complete document database like MongoDB. It uses version numbers
to handle migrations, and you can specify custom logic to run by
providing an `onupgrade` callback that runs whenever the version
changes.

The bare-bones API is pretty awful though. A series of wrappers exists,
as is usual in the JavaScript land. Some of these are
[idb](https://github.com/jakearchibald/idb), [dexie](https://dexie.org/)
and [localForage](https://github.com/localForage/localForage). Of these,
idb is probably the lightest, most stripped down. For example, opening a
database with idb might look like the following:

```javascript
export async function openDatabase() {
  return await idb.openDB(DB_NAME, DB_VERSION, {
    upgrade(db, oldVersion, newVersion, transaction) {
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME);
      }
    },
  });
}
```

As you can see, on the upgrade callback we check whether a certain store
already exists in the database before attempting to create it. This is a
recommended approach to handling migrations with IndexedDB.

IndexedDB offers querying for simple key-value pairs, or more complex
queries that use cursors and indexes to perform filtering as in SQL
where clauses. We won't go down that rabbit hole here, but I encourage
you to take a look at the official documentation or the book mentioned
at the start of this post.

IndexedDB is a very powerful tool at the disposal of the modern web
developer that solves all the local data storage needs your PWA may
have.

## Notifications

The web has, and has had for a time now, the Notifications
API[6](#footnote-6){#footnote-anchor-6 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}. It works similar
to how notifications work on Android: you ask the user for permission to
show them notifications and, if they agree, you can proceed to spam them
in an asynchronous fashion. Take a look at this snippet taken from the
MDN Docs:

```javascript
function notifyMe() {
  if (!("Notification" in window)) {
    // Check if the browser supports notifications
    alert("This browser does not support desktop notification");
  } else if (Notification.permission === "granted") {
    const notification = new Notification("Hi there!");
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission().then((permission) => {
      if (permission === "granted") {
        const notification = new Notification("Hi there!");
        // …
      }
    });
  }
}
```

Pretty straight forward. We check for notifications support and whether
the user has given consent. If so, then we literally just *create* the
Notification. Else, we request for permission and hope for the best.
Note that, as a general guideline, we don't want to ask for consent
right off the bat. We should wait for the user to *want* to give
consent. For example, in a hotel booking application we could ask
whether they want to be notified of future changes to their
reservations[7](#footnote-7){#footnote-anchor-7 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}.

We talked about basic notifications in this post, but another popular
kind are [push
notifications](https://www.ibm.com/es-es/topics/push-notifications).
These allow your server to send notifications about different events to
your clients, such as a daily reminder at 3AM to go to sleep before the
devil's hour. Push notifications are out of the scope of this post, but
they [can be
done](https://developer.mozilla.org/en-US/docs/Web/API/Push_API).

## Content sharing

At this point, you know the drill. Sharing with other applications? Yes,
there's a [web API for
that](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share).
This API is special in that it is usually not available on desktop
devices. It is intended to be used with mobile devices' native sharing
mechanism. An example from an application I developed recently:

```javascript
app.ports.shareHorario.subscribe((serHorario) => {
  if (
    navigator.canShare &&
    "share" in navigator &&
    typeof navigator.share === "function"
  ) {
    navigator.share({
      title: "Horario de corte",
      text: serHorario,
    });
  } else {
    ui("#cant-share-snackbar");
  }
});
```

We first check for the API availability, since it is usually not
available on desktop for example, and then call `navigator.share`
providing parameters such as the `title` and the `text` to be shared.
Another option would be to share a URL providing the `url `parameter.
This is usually done for sharing links to specific resources of your
site that you want your friends or family to see.

## Native widgets

Ok, you got me. Native widgets are not possible for PWAs. I admit this
is a drawback, and it is one of the most common complaints I hear of
Flutter for example. There are ways to emulate them though. There is no
shortage of Material UI CSS libraries like [Beer
CSS](https://www.beercss.com/) (a personal favorite), and I've seen one
or two for Cupertino as well.

But instead of trying to reinvent the wheel, I invite you to think about
what is it that native widgets offer that other CSS based solutions do
not. I can think of one: familiarity. Apple and Google have been
brainwashing users to like certain UI styles for years. The fact that
both Material and Cupertino exist, and look so different, is enough
proof that they don't have anything special that cannot be achieved with
CSS. Furthermore, UI guidelines are constantly changing and I am sure 10
years from now things will look totally different than they do today.

Therefore, we should focus on delivering a good UX to our users. We
should provide the right affordances, make intuitive, easy to navigate
and use user interfaces and all else will follow. We want our users to
be able to use our app and do it efficiently. Fashion is fleeting, but
UX is 4ever.

## Closing thoughts

PWAs have little, if anything, to envy from native mobile applications.
With all the web APIs available today, developers can offer the same
offline-first experience and functionality such as notifications and
local storage as any iOS or Android app.

Moreover, the web is an open platform. It is not owned by an evil
corporation like Apple or Google, and anyone can target it at no cost.
Furthermore, the advent of open source projects like
[LadyBird](https://ladybird.org/) and technologies like WebAssembly is a
glimmer of hope for the future. One day we may have a platform where we
can focus on delivering the best possible experience to help our users
solve their needs, without having to deal with the economic interests of
third parties. It is in the hands of us, users and developers, to push
the world in the right direction.

I am excited about the future of the web, and I hope this post made you
share that sentiment as well, if just a little.

:::: {.footnote component-name="FootnoteToDOM"}
[1](#footnote-anchor-1){#footnote-1 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[2](#footnote-anchor-2){#footnote-2 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[3](#footnote-anchor-3){#footnote-3 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/API/Background_Synchronization_API
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[4](#footnote-anchor-4){#footnote-4 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[5](#footnote-anchor-5){#footnote-5 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[6](#footnote-anchor-6){#footnote-6 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://developer.mozilla.org/en-US/docs/Web/API/Notification
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[7](#footnote-anchor-7){#footnote-7 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://www.amazon.com/Building-Progressive-Web-Apps-Bringing/dp/1491961651/ref=sr_1_1?crid=1WVAY38U14QZW&dib=eyJ2IjoiMSJ9.Xl0BRDNY8X7v0O5h005aroGt-LgoPjkS-E8ALegCLFHO6XRCBeD1mEUQRs_93-tF559BkSdernKTLtv0IlQ_JZqXfyyk1UV6p8XS1CuIfhf5_tQc7BqwmSEw09YrCSbWzVVmZcczdoj3X3bV-AbIxbuGn6VWdkWM7MF3E5vj-LBvKdW5PkiMiYUtHQcI-J9VNL9YWrLWD3inRotQECjGt1_GMKIE4uukxha7B7TIlc0.G4JUCkb3_g5UvCXdkFRG7AAgAIpMEpuCjVlE0doMdP0&dib_tag=se&keywords=building+progressive+web+apps&qid=1729984198&sprefix=building+progressive+w%2Caps%2C1334&sr=8-1
:::
::::
