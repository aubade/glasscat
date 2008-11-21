mimedir = $(datadir)/mime/packages
mime_DATA = glasscat-mime.xml

schemasdir   = $(GCONF_SCHEMA_FILE_DIR)
schemas_DATA = glasscat.schemas

icon16dir = $(datadir)/icons/hicolor/16x16/apps
icon16_DATA = 16x16/glasscat.png
icon24dir = $(datadir)/icons/hicolor/24x24/apps
icon24_DATA = 24x24/glasscat.png
icon32dir = $(datadir)/icons/hicolor/32x32/apps
icon32_DATA = 32x32/glasscat.png
icondir = $(datadir)/icons/hicolor/scalable/apps
icon_DATA = scalable/glasscat.svg

gtk_update_icon_cache = gtk-update-icon-cache -f -t $(datadir)/icons/hicolor
install-data-hook:
		update-mime-database $(datadir)/mime

		@-if test -z "$(DESTDIR)"; then \
				echo "Updating Gtk icon cache."; \
				$(gtk_update_icon_cache); \
		else \
				echo "*** Icon cache not updated.  After install, run this:"; \
				echo "***   $(gtk_update_icon_cache)"; \
		fi

desktopdir = $(datadir)/applications
desktop_DATA = glasscat.desktop

NULL =

uidir = $(pkgdatadir)
ui_DATA =               \
	glasscat-ui.xml \
	glasscat-project-ui.xml \
	$(NULL)

if GCONF_SCHEMAS_INSTALL
install-data-local:
	if test -z "$(DESTDIR)" ; then \
		for p in $(schemas_DATA) ; do \
			GCONF_CONFIG_SOURCE=$(GCONF_SCHEMA_CONFIG_SOURCE) $(GCONFTOOL) --makefile-install-rule $(top_builddir)/data/$$p ; \
		done \
	fi
else
install-data-local:
endif

EXTRA_DIST =            \
	$(mime_DATA)    \
	$(schemas_DATA) \
	$(icon16_DATA)  \
	$(icon24_DATA)  \
	$(icon32_DATA)  \
	$(icon_DATA)    \
	$(desktop_DATA) \
	$(ui_DATA)      \
	$(NULL)
