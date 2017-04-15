Modification of the official "Moono" Skin
=========================================

From the original "Moono" Skin, it replaces, in the collapseed menu, the collapser arrow by the A character.

This is done by adding the folowing at the end of editor*.css:

```css
a.cke_toolbox_collapser{
  width:20px;
  height:11px;
  cursor:pointer !important;
}
.cke_toolbox_collapser.cke_toolbox_collapser_min{
  float:left;
  cursor:pointer !important;
}
.cke_toolbox_collapser.cke_toolbox_collapser_min .cke_arrow{
  cursor:pointer !important;
}
```

License
-------

Copyright (c) 2003-2016, CKSource - Frederico Knabben. All rights reserved.

For licensing, see LICENSE.md or [http://ckeditor.com/license](http://ckeditor.com/license)
