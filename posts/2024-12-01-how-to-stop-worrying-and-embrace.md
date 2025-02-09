---
title: How to stop worrying and embrace micro...frontends?
---

If you've never heard the term, I wouldn't blame you. Who on their right
mind would think of bringing microservices madness to good ol'
JavaScript land? The idea of microfrontends first appeared circa 2016
[1](#footnote-1){#footnote-anchor-1 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}, with the goal of
building frontend web applications that are a composition of features
that can be independently developed and deployed. <span></span><!--more--> This sounds like a
dream for modern day agile workflows. But should you try microfrontends?
If so, what are the trade-offs? In this post we'll explore my experience
microfrontending one of my work projects. Ready? Let's f\*cking go!

<div>

------------------------------------------------------------------------

</div>

In this post we explore my experience moving one of my work projects
towards a microfrontend architecture, but we don't do a deep dive into
the concept of microfrontends. For that, I recommend you read this
wonderful post on the Martin Fowler blog: [Micro
Frontends](https://martinfowler.com/articles/micro-frontends.html).

<div>

------------------------------------------------------------------------

</div>

## But why?

Indeed, why would I go out of my way to complicate my sweet monolithic
web app and tread in the muddy waters of Microfrontend Land? Turns out,
I had already read about microfrontends a while ago and was waiting for
the perfect opportunity to try them out. It just so happened that one of
my work projects found itself in a particular position that made it the
perfect victim of the metamorphic process.

The project is your run-of-the-mill CRUD UI with a couple of different
modules with well defined boundaries. Initially it was written in
Next.js, but I decided to make the migration to SvelteKit early on. I
came to regret this choice early on as well.

Svelte's 4 reactivity model is - well, it sucks. It has weird,
non-intuitive edge cases and works through compiler magic so you can't
really use the same reactivity principles in reusable functions for
example. It honestly doesn't feel like a production ready web framework.
Much of this is supposedly fixed in Svelte 5, but migrating might as
well amount to rewriting the whole application, and many of the
libraries we are using don't work well with Svelte 5 yet. So yeah, I
wanted out.

The project was supposed to be done, so I was gonna let it be. Until one
day God smiled upon me and whispered in my ear "*thou shall write a new
module*". The universe was telling me to microfrontend all over the
place. So I did.

The new feature was a single screen for creating a resource. It would be
activated on the click of a button in an existing module, so I just
needed to inject the microfrontend on the page at that moment. I had the
perfect excuse to start the migration (again), I had the time and I had
the tools.

## How it works

> From JavaScript you come, and to JavaScript you shall return

React, Angular, Vue, Astro, Solid; in the end, it's all just JavaScript.
The idea of microfrontends is that each module of your application
resides in a different project that can be developed, tested and
deployed independently from the rest of your application. After the
build step, all projects should ideally produce a single `bundle.js`
file that you can include in your main application. There are many
things that need to be taken into consideration at the integration
point, such as: how to perform the integration, how to provide
dependencies (e.g. auth tokens) to the microfrontend and how can the
microfrontend communicate back to the main carcass? Let's explore these.

### Integration approaches

Integrating your microfrontends into your main application can be done
in a number of ways. From the humble iframe to custom libraries and the,
loved by many and hated by none, web-components. You can read the
article linked above for an overview on each of these approaches. The
one I opted for and the one they recommend in that article is runtime
integration via JavaScript.

Basically, each microfrontend defines two functions on the global window
object: one for mounting it and one for unmounting it. In my
microfrontend, it looks like this:

::: captioned-image-container
<figure>
<a
href="https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png"
class="image-link image2 is-viewable-img" target="_blank"
data-component-name="Image2ToDOM"></a>
<div class="image2-inset">
<img
src="https://substack-post-media.s3.amazonaws.com/public/images/3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png"
class="sizing-normal"
data-attrs="{&quot;src&quot;:&quot;https://substack-post-media.s3.amazonaws.com/public/images/3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png&quot;,&quot;srcNoWatermark&quot;:null,&quot;fullscreen&quot;:null,&quot;imageSize&quot;:null,&quot;height&quot;:905,&quot;width&quot;:1456,&quot;resizeWidth&quot;:728,&quot;bytes&quot;:241202,&quot;alt&quot;:null,&quot;title&quot;:null,&quot;type&quot;:&quot;image/png&quot;,&quot;href&quot;:null,&quot;belowTheFold&quot;:true,&quot;topImage&quot;:false,&quot;internalRedirect&quot;:null,&quot;isProcessing&quot;:false}"
srcset="https://substackcdn.com/image/fetch/w_424,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png 424w, https://substackcdn.com/image/fetch/w_848,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png 848w, https://substackcdn.com/image/fetch/w_1272,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png 1272w, https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F3443e9b6-6b4e-41a4-bb03-0244277e8495_1676x1042.png 1456w"
sizes="100vw" loading="lazy" width="728" height="452" />
<div class="image-link-expand">
<div class="pencraft pc-display-flex pc-gap-8 pc-reset">
<div class="pencraft pc-reset icon-container restack-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJlZnJlc2gtY3ciPjxwYXRoIGQ9Ik0zIDEyYTkgOSAwIDAgMSA5LTkgOS43NSA5Ljc1IDAgMCAxIDYuNzQgMi43NEwyMSA4IiAvPjxwYXRoIGQ9Ik0yMSAzdjVoLTUiIC8+PHBhdGggZD0iTTIxIDEyYTkgOSAwIDAgMS05IDkgOS43NSA5Ljc1IDAgMCAxLTYuNzQtMi43NEwzIDE2IiAvPjxwYXRoIGQ9Ik04IDE2SDN2NSIgLz48L3N2Zz4="
class="lucide lucide-refresh-cw" />
</div>
<div class="pencraft pc-reset icon-container view-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW1heGltaXplMiI+PHBvbHlsaW5lIHBvaW50cz0iMTUgMyAyMSAzIDIxIDkiPjwvcG9seWxpbmU+PHBvbHlsaW5lIHBvaW50cz0iOSAyMSAzIDIxIDMgMTUiPjwvcG9seWxpbmU+PGxpbmUgeDE9IjIxIiB4Mj0iMTQiIHkxPSIzIiB5Mj0iMTAiPjwvbGluZT48bGluZSB4MT0iMyIgeDI9IjEwIiB5MT0iMjEiIHkyPSIxNCI+PC9saW5lPjwvc3ZnPg=="
class="lucide lucide-maximize2" />
</div>
</div>
</div>
</div>
</figure>
:::

This particular microfrontend is written in
Vue[2](#footnote-2){#footnote-anchor-2 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}. As you can see, we
are defining two functions: `mountKCreateAlert` for mounting the
component and `unmountKCreateAlert `for unmounting it. How you include
this in your app shell will differ depending on what specific
technologies you are using. In my case, I took advantage of Svelte's
actions[3](#footnote-3){#footnote-anchor-3 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}:

::: captioned-image-container
<figure>
<a
href="https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png"
class="image-link image2 is-viewable-img" target="_blank"
data-component-name="Image2ToDOM"></a>
<div class="image2-inset">
<img
src="https://substack-post-media.s3.amazonaws.com/public/images/d012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png"
class="sizing-normal"
data-attrs="{&quot;src&quot;:&quot;https://substack-post-media.s3.amazonaws.com/public/images/d012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png&quot;,&quot;srcNoWatermark&quot;:null,&quot;fullscreen&quot;:null,&quot;imageSize&quot;:null,&quot;height&quot;:1247,&quot;width&quot;:1456,&quot;resizeWidth&quot;:null,&quot;bytes&quot;:340338,&quot;alt&quot;:null,&quot;title&quot;:null,&quot;type&quot;:&quot;image/png&quot;,&quot;href&quot;:null,&quot;belowTheFold&quot;:true,&quot;topImage&quot;:false,&quot;internalRedirect&quot;:null,&quot;isProcessing&quot;:false}"
srcset="https://substackcdn.com/image/fetch/w_424,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png 424w, https://substackcdn.com/image/fetch/w_848,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png 848w, https://substackcdn.com/image/fetch/w_1272,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png 1272w, https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd012b621-07ab-46cc-92bd-f7bd881f64b4_1782x1526.png 1456w"
sizes="100vw" loading="lazy" width="1456" height="1247" />
<div class="image-link-expand">
<div class="pencraft pc-display-flex pc-gap-8 pc-reset">
<div class="pencraft pc-reset icon-container restack-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJlZnJlc2gtY3ciPjxwYXRoIGQ9Ik0zIDEyYTkgOSAwIDAgMSA5LTkgOS43NSA5Ljc1IDAgMCAxIDYuNzQgMi43NEwyMSA4IiAvPjxwYXRoIGQ9Ik0yMSAzdjVoLTUiIC8+PHBhdGggZD0iTTIxIDEyYTkgOSAwIDAgMS05IDkgOS43NSA5Ljc1IDAgMCAxLTYuNzQtMi43NEwzIDE2IiAvPjxwYXRoIGQ9Ik04IDE2SDN2NSIgLz48L3N2Zz4="
class="lucide lucide-refresh-cw" />
</div>
<div class="pencraft pc-reset icon-container view-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW1heGltaXplMiI+PHBvbHlsaW5lIHBvaW50cz0iMTUgMyAyMSAzIDIxIDkiPjwvcG9seWxpbmU+PHBvbHlsaW5lIHBvaW50cz0iOSAyMSAzIDIxIDMgMTUiPjwvcG9seWxpbmU+PGxpbmUgeDE9IjIxIiB4Mj0iMTQiIHkxPSIzIiB5Mj0iMTAiPjwvbGluZT48bGluZSB4MT0iMyIgeDI9IjEwIiB5MT0iMjEiIHkyPSIxNCI+PC9saW5lPjwvc3ZnPg=="
class="lucide lucide-maximize2" />
</div>
</div>
</div>
</div>
</figure>
:::

There are a few things to note. First, we are dynamically creating the
script tag and appending it to the head of the document. This might have
some performance implications, so you might want to preload the script
in some way or cache it with a service
worker[4](#footnote-4){#footnote-anchor-4 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"}. Second, we call
the unmount function when the component is destroyed. This is crucial to
avoid memory leaks, since we are now in charge of the microfrontend's
framework lifecycle. Lastly, I am using the provided name as the id of
the element to mount the microfrontend on, but I could also have opted
for using `element.id`.

The action can be used like this:

::: captioned-image-container
<figure>
<a
href="https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png"
class="image-link image2 is-viewable-img" target="_blank"
data-component-name="Image2ToDOM"></a>
<div class="image2-inset">
<img
src="https://substack-post-media.s3.amazonaws.com/public/images/a6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png"
class="sizing-normal"
data-attrs="{&quot;src&quot;:&quot;https://substack-post-media.s3.amazonaws.com/public/images/a6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png&quot;,&quot;srcNoWatermark&quot;:null,&quot;fullscreen&quot;:null,&quot;imageSize&quot;:null,&quot;height&quot;:951,&quot;width&quot;:1456,&quot;resizeWidth&quot;:null,&quot;bytes&quot;:305393,&quot;alt&quot;:null,&quot;title&quot;:null,&quot;type&quot;:&quot;image/png&quot;,&quot;href&quot;:null,&quot;belowTheFold&quot;:true,&quot;topImage&quot;:false,&quot;internalRedirect&quot;:null,&quot;isProcessing&quot;:false}"
srcset="https://substackcdn.com/image/fetch/w_424,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png 424w, https://substackcdn.com/image/fetch/w_848,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png 848w, https://substackcdn.com/image/fetch/w_1272,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png 1272w, https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6d68bc8-d596-4fa9-a375-fe0b9252c513_1782x1164.png 1456w"
sizes="100vw" loading="lazy" width="1456" height="951" />
<div class="image-link-expand">
<div class="pencraft pc-display-flex pc-gap-8 pc-reset">
<div class="pencraft pc-reset icon-container restack-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJlZnJlc2gtY3ciPjxwYXRoIGQ9Ik0zIDEyYTkgOSAwIDAgMSA5LTkgOS43NSA5Ljc1IDAgMCAxIDYuNzQgMi43NEwyMSA4IiAvPjxwYXRoIGQ9Ik0yMSAzdjVoLTUiIC8+PHBhdGggZD0iTTIxIDEyYTkgOSAwIDAgMS05IDkgOS43NSA5Ljc1IDAgMCAxLTYuNzQtMi43NEwzIDE2IiAvPjxwYXRoIGQ9Ik04IDE2SDN2NSIgLz48L3N2Zz4="
class="lucide lucide-refresh-cw" />
</div>
<div class="pencraft pc-reset icon-container view-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW1heGltaXplMiI+PHBvbHlsaW5lIHBvaW50cz0iMTUgMyAyMSAzIDIxIDkiPjwvcG9seWxpbmU+PHBvbHlsaW5lIHBvaW50cz0iOSAyMSAzIDIxIDMgMTUiPjwvcG9seWxpbmU+PGxpbmUgeDE9IjIxIiB4Mj0iMTQiIHkxPSIzIiB5Mj0iMTAiPjwvbGluZT48bGluZSB4MT0iMyIgeDI9IjEwIiB5MT0iMjEiIHkyPSIxNCI+PC9saW5lPjwvc3ZnPg=="
class="lucide lucide-maximize2" />
</div>
</div>
</div>
</div>
</figure>
:::

As you can see, this makes it incredibly easy to include a microfrontend
in your application. Here, we are using environment variables to locate
our microfrontend bundles, but it might be necessary to use a more
sophisticated approach as the number of microfrontends approaches
infinity. Even so, it doesn't get much simpler than this.

### Communicating: from shell to microfrontend

If we look at our microfrontend as a function, we might say it goes from
some parameters to some JavaScript. These parameters are how the app
shell can communicate to the microfrontend to provide everything it
needs to take over the world. A parameter common to most microfrontends
will be the mount point: the element or identifier of where the
microfrontend should attach itself to. Other parameters may differ. In
my case, the parameters my microfrontend needed are described by the
following TypeScript interface:

::: captioned-image-container
<figure>
<a
href="https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png"
class="image-link image2 is-viewable-img" target="_blank"
data-component-name="Image2ToDOM"></a>
<div class="image2-inset">
<img
src="https://substack-post-media.s3.amazonaws.com/public/images/30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png"
class="sizing-normal"
data-attrs="{&quot;src&quot;:&quot;https://substack-post-media.s3.amazonaws.com/public/images/30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png&quot;,&quot;srcNoWatermark&quot;:null,&quot;fullscreen&quot;:null,&quot;imageSize&quot;:null,&quot;height&quot;:530,&quot;width&quot;:1052,&quot;resizeWidth&quot;:null,&quot;bytes&quot;:93574,&quot;alt&quot;:null,&quot;title&quot;:null,&quot;type&quot;:&quot;image/png&quot;,&quot;href&quot;:null,&quot;belowTheFold&quot;:true,&quot;topImage&quot;:false,&quot;internalRedirect&quot;:null,&quot;isProcessing&quot;:false}"
srcset="https://substackcdn.com/image/fetch/w_424,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png 424w, https://substackcdn.com/image/fetch/w_848,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png 848w, https://substackcdn.com/image/fetch/w_1272,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png 1272w, https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F30fecad2-e073-4460-9635-0e79a3572fd0_1052x530.png 1456w"
sizes="100vw" loading="lazy" width="1052" height="530" />
<div class="image-link-expand">
<div class="pencraft pc-display-flex pc-gap-8 pc-reset">
<div class="pencraft pc-reset icon-container restack-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXJlZnJlc2gtY3ciPjxwYXRoIGQ9Ik0zIDEyYTkgOSAwIDAgMSA5LTkgOS43NSA5Ljc1IDAgMCAxIDYuNzQgMi43NEwyMSA4IiAvPjxwYXRoIGQ9Ik0yMSAzdjVoLTUiIC8+PHBhdGggZD0iTTIxIDEyYTkgOSAwIDAgMS05IDkgOS43NSA5Ljc1IDAgMCAxLTYuNzQtMi43NEwzIDE2IiAvPjxwYXRoIGQ9Ik04IDE2SDN2NSIgLz48L3N2Zz4="
class="lucide lucide-refresh-cw" />
</div>
<div class="pencraft pc-reset icon-container view-image">
<img
src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyMCIgaGVpZ2h0PSIyMCIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLW1heGltaXplMiI+PHBvbHlsaW5lIHBvaW50cz0iMTUgMyAyMSAzIDIxIDkiPjwvcG9seWxpbmU+PHBvbHlsaW5lIHBvaW50cz0iOSAyMSAzIDIxIDMgMTUiPjwvcG9seWxpbmU+PGxpbmUgeDE9IjIxIiB4Mj0iMTQiIHkxPSIzIiB5Mj0iMTAiPjwvbGluZT48bGluZSB4MT0iMyIgeDI9IjEwIiB5MT0iMjEiIHkyPSIxNCI+PC9saW5lPjwvc3ZnPg=="
class="lucide lucide-maximize2" />
</div>
</div>
</div>
</div>
</figure>
:::

Ignore the callbacks for now. Authentication is usually a cross-cutting
concern, and as such, it will cut across all of our microfrontends
(ouch!). In this case, we are using cookies (unfortunately), so the app
shell should provide our microfrontend with the authentication cookie
for it to be able to make requests to our API. Currently, we have a
single monolithic backend API, but in an ideal world each microfrontend
would have its own backend (also known as a Backend for Frontend, BFF).

Now, let's talk about those callbacks.

### Communicating: from microfrontend to shell

Microfrontends have many reasons to want to communicate back to the app
shell, such as reporting error and success conditions. There are many
ways this communication can be performed: custom events, custom events +
web components; etc. But in the spirit of KISS, we opted for plain
JavaScript callbacks à la React.

The microfrontends would receive a callback for each event the app shell
could be interested in. In our case, this means notifying of successful
resource creation, or communicating an error. The shell can then do
something like show a toast with an appropriate message to the user.

There's really not much more to this. Just keep it simple, ~~stupid~~
silly.

## Styling

I'm going to be honest, I'm more of a backend guy (I don't feel much
love for web development in general, but hey, I got to eat), so UI/UX
has always been the bane of my existence. Now, with microfrontends, we
need to keep styling in sync for multiple different projects. This is a
challenge, but it's not a new problem. Many solutions exist such as a
component libraries, common CSS ~~shits~~ sheets, CSS-in-JS; etc. But it
*was* a problem for me because my styling skills are literally
non-existent.

Luckily, shadcn[5](#footnote-5){#footnote-anchor-5 .footnote-anchor
component-name="FootnoteAnchorToDOM" target="_self"} exists. shadcn is a
component library that uses TailwindCSS. It is used by including the
code for the components in your project, so you have full access to it
and can modify it as necessary. shadcn components look good, are highly
customizable, and the library has been ported to most major web
frameworks (the real deal is made for React).

We were already using shadcn in the SvelteKit application, so using it
for the Vue microfrontend was a no brainer. With little effort, the
components look literally the same. Or at least similar enough that my
robotic eyes can't tell the difference.

Since shadcn uses TailwindCSS, the theme is customized in a single CSS
file, so we just copy-pasted the file from one project to the other.
This has worked fine for us for the moment, and honestly I can see us
doing the same or building a template for new microfrontends that
already includes this configuration. Again, KISS.

## Testing

Since each microfrontend contains a single feature, testing it is much
easier than orchestrating the entire application to test that isolated
piece of functionality. Also, as we already saw, each microfrontend
receives its dependencies quite explicitly, so providing or mocking them
during a test also becomes easier.

Microfrontend tests should be quick and cheap to run, so the CI pipeline
is also fast. This in turn allows each microfrontend team to work in an
agile environment with a faster feedback loop than if there were
multiple teams working in the same monolith.

Testing the integration points and end-to-end tests would require more
configuration, and we haven't gotten to that point yet in the project.
While I don't have much to say here based on direct experience, I
believe the ability to test easily at more granular levels it still
quite valuable for the overall testing strategy.

## Deployment

Arguably, one of the most valuable aspects of microfrontends is that it
allows different parts of the application to be deployed and rolled-back
independently. Teams are not blocked by each other, waiting for the
planets to align in order to be able to trigger a deployment.

At the app shell level, some configuration is needed. As we saw earlier,
in my project we are using environment variables to locate the
microfrontend bundles, but you might want to use a config file of some
sort for this. I'm considering Dhall[6](#footnote-6){#footnote-anchor-6
.footnote-anchor component-name="FootnoteAnchorToDOM" target="_self"}
because pain makes me feel alive.

We are using NGINX to expose our services and have configured the
following mapping to expose the microfrontend bundles to the main
application as static assets:

    location /static/ {
        alias /var/www/example.com/current/static/;
    }

As you can see, it's pretty damn simple. All bundles go in
`/var/www/example.com/current/static/` and profit. We are not
considering things like compression and stuff just yet. The deployment
of the bundles can be automated in a CI pipeline, and the app shell will
pick the new ones immediately as long as server caching is properly
configured.

## The Bad

Everything in software engineering is about trade-offs, so what are we
trading-off here?

-   **Bundle size** Packaging a whole Vue application inside a SvelteKit
    application seems, well, not ideal. The amount of work needed to
    pull each microfrontend can quickly get out of hand. As the meme
    goes, "no tengo pruebas pero tampoco
    dudas"[7](#footnote-7){#footnote-anchor-7 .footnote-anchor
    component-name="FootnoteAnchorToDOM" target="_self"}. A key to
    reducing bundle size when using a microfrontend architecture is to
    share as much code as possible (your own and third party), while
    also minimizing coupling. Easy enough, right?

-   **Deployment requires more configuration** We talked about this
    already. Microfrontends come with added complexity. But I would
    argue this complexity is really minimal, and with good processes and
    automated deployments this pain is not really something you can
    feel.

-   **Increased cognitive load** Keeping track of the whole system that
    is scattered across many small components is always harder than just
    being able to have a holistic look over the whole codebase. Good
    documentation is key to keep everyone on page with the status of the
    project.

## Conclusion

Phew, we are finally here. Microfrontends come with challenges, but I
argue that the benefits outweigh the costs. I think they are an
effective way to decouple software at the frontend level, and to
streamline the development process across multiple teams.

I hope after reading this post you are at least curious about
microfrontends, and I would absolutely love to hear your opinions or
experience with them. As for me, I will be adopting microfrontends more
in the near future. If it backfires, I'll let you know in another post.

Until then, keep coding.

:::: {.footnote component-name="FootnoteToDOM"}
[1](#footnote-anchor-1){#footnote-1 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://micro-frontends.org/
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[2](#footnote-anchor-2){#footnote-2 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://vuejs.org/
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[3](#footnote-anchor-3){#footnote-3 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://joyofcode.xyz/svelte-actions-guide
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
https://ui.shadcn.com/
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[6](#footnote-anchor-6){#footnote-6 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://dhall-lang.org/
:::
::::

:::: {.footnote component-name="FootnoteToDOM"}
[7](#footnote-anchor-7){#footnote-7 .footnote-number
contenteditable="false" target="_self"}

::: footnote-content
https://meme.fandom.com/es/wiki/No_Tengo_Pruebas_Pero_Tampoco_Dudas
:::
::::
