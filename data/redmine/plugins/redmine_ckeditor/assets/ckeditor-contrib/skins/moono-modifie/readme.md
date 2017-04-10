Modification of the official "Moono" Skin
=========================================

From the original "Moono" Skin, it replaces, in the collapseed menu, the collapser arrow by the A character.

This is done by adding the folowing at the end of editor*.css:

```css
a.cke_toolbox_collapser{
  width:16px;
  height:16px;
}
.cke_toolbox_collapser.cke_toolbox_collapser_min{
  width:16px;
  height:16px;
  background: url('icons.png?t=G6DE') no-repeat 0 -408px !important;
  background-size:auto;
}
.cke_toolbox_collapser.cke_toolbox_collapser_min .cke_arrow{
  opacity: 0;
}
```

License
-------

Copyright (c) 2003-2016, CKSource - Frederico Knabben. All rights reserved.

For licensing, see LICENSE.md or [http://ckeditor.com/license](http://ckeditor.com/license)
