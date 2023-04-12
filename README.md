# Industrial

<!-- * [Français][doc-fr]) -->

This module is designed for marketers or communication team to create quickly and easily
**landing pages** or **microsites**.

This module is a Jahia *ready to use* implementation of the template [industrial][industrial-website],
based on the open source toolkit [Bootstrap 4][bs-website].
Following the concept of bootstrap 4, the template can be modified or used as his.

From a technical point of view, this module is a `template set`. But, it can be also used to demonstrate
the integration of an external Digital Asset Manager (DAM) with Jahia jContent. Indeed, with this modules
you can see the [Widen Picker Accelerator][wpa:gitUrl] or [Cloudinary Picker Accelerator][cpa:gitUrl] in
action within complex content like carousel.

> Note: The DAM integration required a [Widen][widen:url] or [Cloudinary][cloudinary:url] account.
 
> Note: even if you do not have a Widen or Cloudinary account you can use this template set.
> But the external DAM capabilities will not be functional, and the media contents will be the one
> provided by default. If you need more media contents for a demo, you can install
> the relative module [Industrial Media Component][imc:gitUrl].
 
- [Module content](#module-content)
- [Quick Start](#quick-start)
    - [Install dependencies](#install-dependencies)
        - [Install the module `Bootstrap 4 Package`](#install-the-module-bootstrap-4-package)
        - [Install the module `animate`](#install-the-module-animate)
        - [Install the module `dam-selector`](#install-the-module-dam-selector)
        - [Install the module `codeMirror-editor`](#install-the-module-codemirror-editor)
    - [Install the Industrial module](#install-the-industrial-module)
- [Create a new website using `industrial` template set](#create-a-new-website-using-industrial-template-set)
- [Contribute with prepackage components](#contribute-with-prepackage-components)
- [Google Analytics site settings](#google-analytics-site-settings)

## Module content
This module contains:
- A set of Components that a contributor can copy/past/update to create it own website:
    - Carousel (2 types: heading and testimonial)
    
        ![][100]
        
        ![101]
        
    - Gallery image
    
        ![102]
        
    - Features list
    
        ![104]
        
    - Cards elements
    
        ![105]
        
    - Text and illustration
    
        ![103]
        
    - Navigation bar
    - Footer components (about, contact, navigation)
    - ...
- Two templates:
    - A `Free` template to start from an empty page where contributor can copy/past/update
    the previous prepackaged components.
    - A `Structured` template to create a page with a predefined and fixed HTML grid.
- A set of Page samples to present the type of website a contributor can create. Components can be
    copy and paste from the Industrial pages.



## Quick Start
Industrial Template Set module depends on:
1. bootstrap 4
2. animate
3. widen picker

Thus, before to install and to run the Industrial module we need to ensure dependencies are satisfied.

### Install dependencies

#### Install the module `Bootstrap 4 Package`: 
1. In jContent, go to `Administration` panel.
2. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
3. From the right panel, click `Available modules` and search for **Bootstrap 4 Package**.

    ![200]
    
1. Click the icon ![201] in the right of the package to download and install the module

#### Install the module `animate`: 
1. In jContent, go to `Administration` panel.
2. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
3. From the right panel, click `Available modules` and search for **animate**.

    ![202A]
    
1. Click the icon ![201] in the right of the package to download and install the module

#### Install the module `Dam Selector`: 

1. In jContent, go to `Administration` panel.
2. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
3. From the right panel, click `Available modules` and search for **dam**.

    ![205]
    
4. Click the icon ![201] in the right of the package to download and install the module
<!-- 5. To request the Widen server, you have to configure the module with your Widen API access information.
Have a look at the [post-install][wpa:postInstall] process. -->

#### Install the module `CodeMirror Editor`:

1. In jContent, go to `Administration` panel.
2. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
3. From the right panel, click `Available modules` and search for **codeMirror**.

   ![206]

4. Click the icon ![201] in the right of the package to download and install the module

### Install the Industrial module

Now the dependencies are installed, industrial module is ready to be deployed.

#### Snapshot From the source
1. Download the zip archive of the latest release.
2. Go to the root of the repository.
1. Run the command `mvn clean install`. This create a jar file in the *target* repository.
    > you must have a **java sdk** and **maven** installed
1. In jContent, go to `Administration` panel.
1. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
1. From the right panel, click `SELECT MODULE` and select the jar file in the *target* repository.
1. Click `UPLOAD`.

#### From the store
1. In jContent, go to `Administration` panel.
2. In the `Server` section expand the `Modules and Extensions` entry and click `Modules`.
3. From the right panel, click `Available modules` and search for **industrial**.

    <!--![200]-->
    
4. Click the icon ![201] in the right of the package to download and install the module.  
 

## Create a new website using `industrial` template set

The module industrial is now installed and ready to use. The module is a Jahia *template set*, it is enabled when a new website is created.

To create a new website using `industrial` follow the next steps:
1. Goto `Administration` mode
2. Click `Projects` entry and click `CREATE` in the right panel

    ![Create a new web project][000]

3. Fill the website name and key with the name you want and click NEXT

    ![Create a new web project][001]

4. Select the template set `industrial` and choose modules to be deployed:
   1. (optional) `Cloudinary`: to enable external DAM capabilities. Require a Cloudinary account.
   2. (optional) `Jahia Google Analytics`: to enable the `Google Analytics site settings`
         entry used to include your google analytics tag.
   3. (optional) `Widen Picker`: to enable external DAM capabilities. Require a Widen account .
   
    ![Create a new web project][002]
    
5. Review the information and click SAVE

    ![003]
    
6. The web project is ready you can start to edit it

    ![005]

## Contribute with prepackage components
By default, the module deploys 4 pages of which 3 are examples, and they can be deleted. But, keep in mind
you can copy/past/update component from the industrial page. In the example below, we copy the carousel
component before to past it later in the Home page.

![801]

<!--
## Use Jahia `Forms` and `jExperience` with an Industrial website
[read more][forms-jx]
-->

## Google Analytics site settings
[read more][google-analytics]

[000]: doc/images/000_create_new_site.png
[001]: doc/images/001_create_new_site.png
[002]: doc/images/002_create_new_site.png
[003]: doc/images/003_create_new_site.png
[005]: doc/images/005_newSite.png
[100]: doc/images/100_component_carousel.png
[101]: doc/images/101_component_carousel.png
[102]: doc/images/102_component_gallery.png
[103]: doc/images/103_component_text.png
[104]: doc/images/104_component_features.png
[105]: doc/images/105_component_cards.png
[200]: doc/images/200_modules_B4.png
[201]: doc/images/201_modules_download_icon.png
[202A]: doc/images/202_modules_animate.png
[202I]: doc/images/202_modules_industrial.png
[205]: doc/images/205_module_damSelector.png
[206]: doc/images/206_module_codeMirror.png
[801]: doc/images/801_site_sample.png

[forms-jx]: doc/en/formsAndJexperience.md
[google-analytics]:doc/en/googleAnalytics.md

[bs-website]: https://getbootstrap.com/docs/
[industrial-website]: https://colorlib.com/wp/template/industrial/
[widen-website]: https://www.widen.com/
[wpa:postInstall]: https://github.com/Jahia/widen-asset-picker#post-install-optional
[wpa:gitUrl]: https://github.com/Jahia/widen-asset-picker
[cpa:gitUrl]:https://github.com/Jahia/cloudinary-picker
[imc:gitUrl]: https://github.com/hduchesne/industrial-media-component
[widen:url]: https://www.widen.com/
[cloudinary:url]: https://cloudinary.com/
[doc-fr]: doc/fr/README.md
