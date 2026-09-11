;; doom-evidlo-theme.el --- inspired by Textmate's Monokai -*- no-byte-compile: t; -*-
(require 'doom-themes)

;;
(defgroup doom-evidlo-theme nil
  "Options for doom-molokai."
  :group 'doom-themes)

(defcustom doom-evidlo-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-evidlo-theme
  :type 'boolean)

(defcustom doom-evidlo-comment-bg doom-evidlo-brighter-comments
  "If non-nil, comments will have a subtle, darker background. Enhancing their
legibility."
  :group 'doom-evidlo-theme
  :type 'boolean)

(defcustom doom-evidlo-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'doom-evidlo-theme
  :type '(choice integer boolean))

;;
(def-doom-theme doom-evidlo
  "A dark, vibrant theme inspired by Textmate's Monokai."

  ;; name        gui       256       16
  ((bg         '("#ffffff" "#ffffff" "#ffffff"    ))
   (bg-alt     '("#ffffff" "#ffffff" "#ffffff"   ))
   (base0      '("#FFFFFF" "black"   "black"      ))
   (base1      '("#ffffff" "#ffffff" "brightblack"))
   (base2      '("#ffffff" "#ffffff" "brightblack"))
   (base3      '("#ffffff" "#ffffff" "brightblack"))
   (base4      '("#ffffff" "#ffffff" "brightblack"))
   (base5      '("#ffffff" "#ffffff" "brightblack"))
   (base6      '("#ffffff" "#ffffff" "brightblack"))
   (base7      '("#ffffff" "#ffffff" "brightblack"))
   (base8      '("#ffffff" "#ffffff" "brightwhite"))
   (fg         '("#ffffff" "#ffffff" "brightwhite"))
   (fg-alt     '("#ffffff" "#ffffff" "white"))

   (grey       '("#ffffff" "#ffffff" "brightblack"))
   (red        '("#ffffff" "#ffffff" "red"))
   (orange     '("#ffffff" "#ffffff" "brightred"))
   (green      '("#ffffff" "#ffffff" "green"))
   (teal       green)
   (yellow     '("#ffffff" "#ffffff" "yellow"))
   (blue       '("#ffffff" "#FFFFFF" "brightblue"))
   (dark-blue  '("#ffffff" "#ffffff" "blue"))
   (magenta    '("#ffffff" "#ffffff" "magenta"))
   (violet     '("#ffffff" "#ffffff" "brightmagenta"))
   (cyan       '("#ffffff" "#ffffff" "brightcyan"))
   (dark-cyan  '("#ffffff" "#FFFFFF" "cyan"))

   ;; face categories
   (highlight      orange)
   (vertical-bar   (doom-lighten bg 0.1))
   (selection      base5)
   (builtin        orange)
   (comments       (if doom-evidlo-brighter-comments violet base5))
   (doc-comments   (if doom-evidlo-brighter-comments (doom-lighten violet 0.1) (doom-lighten base5 0.25)))
   (constants      orange)
   (functions      green)
   (keywords       magenta)
   (methods        cyan)
   (operators      violet)
   (type           cyan)
   (strings        yellow)
   (variables      fg)
   (numbers        violet)
   (region         base4)
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    base4)
   (vc-added       (doom-darken green 0.15))
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-pad
    (when doom-evidlo-padded-modeline
      (if (integerp doom-evidlo-padded-modeline) doom-evidlo-padded-modeline 4)))

   (modeline-fg nil)
   (modeline-fg-alt base4)

   (modeline-bg base1)
   (modeline-bg-inactive (doom-darken base2 0.2))

   (org-quote `(,(doom-lighten (car bg) 0.05) "#ffffff")))


  ;; --- extra faces ------------------------
  ((lazy-highlight :background violet :foreground base0 :distant-foreground base0 :bold bold)
   (cursor :background magenta)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color modeline-bg-inactive)))

   ;; Font lock
   (font-lock-comment-face
    :foreground comments
    :slant 'italic)
   (font-lock-doc-face
    :foreground doc-comments
    :slant 'italic)
   (font-lock-type-face
    :foreground type
    :slant 'italic)
   
   ;; Centaur tabs
   (centaur-tabs-selected-modified :inherit 'centaur-tabs-selected
                                   :background bg
                                   :foreground yellow)
   (centaur-tabs-unselected-modified :inherit 'centaur-tabs-unselected
                                     :background bg-alt
                                     :foreground yellow)
   (centaur-tabs-active-bar-face :background yellow)
   (centaur-tabs-modified-marker-selected :inherit 'centaur-tabs-selected :foreground fg)
   (centaur-tabs-modified-marker-unselected :inherit 'centaur-tabs-unselected :foreground fg)

   ;; Doom modeline
   (doom-modeline-bar :background yellow)
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'bold :foreground green)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)
   (doom-modeline-buffer-modified :inherit 'bold :foreground orange)

   ((line-number &override) :foreground base5 :distant-foreground nil)
   ((line-number-current-line &override) :foreground base7 :distant-foreground nil)

   (isearch :foreground base0 :background green)

   ;; ediff
   (ediff-fine-diff-A :background (doom-blend magenta bg 0.3) :weight 'bold)

   ;; evil-mode
   (evil-search-highlight-persist-highlight-face :background violet)

   ;; evil-snipe
   (evil-snipe-first-match-face :foreground base0 :background green)
   (evil-snipe-matches-face     :foreground green :underline t)

   ;; flycheck
   (flycheck-error   :underline `(:style wave :color ,red)    :background base3)
   (flycheck-warning :underline `(:style wave :color ,yellow) :background base3)
   (flycheck-info    :underline `(:style wave :color ,green)  :background base3)

   ;; helm
   (helm-swoop-target-line-face :foreground magenta :inverse-video t)

   ;; ivy
   (ivy-current-match :background base3)
   (ivy-minibuffer-match-face-1 :background base1 :foreground base4)

   ;; neotree
   (neo-dir-link-face   :foreground cyan)
   (neo-expand-btn-face :foreground magenta)

   ;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face :foreground magenta)
   (rainbow-delimiters-depth-2-face :foreground orange)
   (rainbow-delimiters-depth-3-face :foreground green)
   (rainbow-delimiters-depth-4-face :foreground cyan)
   (rainbow-delimiters-depth-5-face :foreground magenta)
   (rainbow-delimiters-depth-6-face :foreground orange)
   (rainbow-delimiters-depth-7-face :foreground green)


   ;; --- major-mode faces -------------------
   ;; css-mode / scss-mode
   (css-proprietary-property :foreground keywords)

   ;; markdown-mode
   (markdown-blockquote-face :inherit 'italic :foreground dark-blue)
   (markdown-list-face :foreground magenta)
   (markdown-pre-face  :foreground cyan)
   (markdown-link-face :inherit 'bold :foreground blue)
   ((markdown-code-face &override) :background (doom-lighten base2 0.045))

   ;; org-mode
   ((outline-1 &override) :foreground magenta)
   ((outline-2 &override) :foreground orange)
   (org-ellipsis :foreground orange)
   (org-tag :foreground yellow :bold nil)
   ((org-quote &override) :inherit 'italic :foreground base7 :background org-quote)
   (org-todo :foreground yellow :bold 'inherit)
   (org-list-dt :foreground yellow))


  ;; --- extra variables --------------------
  ;; ()
  )

;;; doom-evidlo-theme.el ends here
