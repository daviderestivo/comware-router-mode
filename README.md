# Comware Router Mode

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![MELPA](https://melpa.org/packages/comware-router-mode-badge.svg)](https://melpa.org/#/comware-router-mode)

An Emacs major mode for editing Comware routers and switches
configuration files.

# Introduction
Taking inspiration from *Noufal Ibrahim* and his
[cisco-router-mode](https://www.emacswiki.org/emacs/cisco-router-mode.el),
I decided to write a major mode for editing Comware routers and
switches configuration files. This mode is still in alpha version.
Please feel free to contribute in improving it.

# Installation
Download and copy comware-router-mode.el into your `~/.emacs.d/lisp`
directory and add the following to your `init.el`.

```
;; Tell Emacs where is your personal elisp lib directory
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; comware-router-mode
;; https://github.com/daviderestivo/comware-router-mode
(load-library "comware-router-mode")
```

or if you prefer to use use-package:

```
;; An Emacs major mode for editing Comware routers and switches
;; configuration files.
(use-package comware-router-mode
  :defer t
  :ensure t)
```

# Keybindings
| Key       | Function                           |
| :---      | :---                               |
| C-j       | comware-router-indent-line         |
| C-c C-l v | comware-router-vrf-list            |
| C-c C-l i | comware-router-interfaces-list     |
| C-c C-l r | comware-router-route-policies-list |
| \<tab\>     | comware-router-code-folding-toggle |

# License
 This file is NOT part of GNU Emacs.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

# Contribution
Feel free to open an issue in case of questions or problems.
Contributions are always welcome.
