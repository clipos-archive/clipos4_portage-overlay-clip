# -*- coding: utf-8 -*-
#
# Adeskbar plugin to create custom dynamic menu.
# Copyright 2011 ANSSI
# Author: Mickaël Salaün <clipos@ssi.gouv.fr>
#
# Distributed under the terms of the GNU General Public License v2

import gtk

settings = {
    'menu_path': 'applications.menu',
    'use_menu_properties': 1
    }

class config(gtk.Frame):
    def __init__(self, conf, ind):
        gtk.Frame.__init__(self)
        self.conf = conf
        self.ind = ind

        self.set_border_width(5)
        framebox = gtk.HBox(False, 0)
        framebox.set_border_width(5)
        framebox.set_spacing(10)
        self.add(framebox)

        for key in settings:
            if not key in conf.launcher[ind]:
                conf.launcher[ind][key] = settings[key]

        self.settings = conf.launcher[ind]

        table = gtk.Table(2, 2, False)

        label = gtk.Label("Menu file :")
        label.set_alignment(0, 0.5)
        # TODO: gtk.FileChooserDialog
        self.menu_entry = gtk.Entry()
        self.menu_entry.set_text(self.settings['menu_path'])
        table.attach(label, 0, 1, 0, 1)
        table.attach(self.menu_entry, 1, 2, 0, 1)

        self.use_menu_properties = gtk.CheckButton('Use the root menu properties (icon and tooltip)')
        self.use_menu_properties.set_active(int(self.settings['use_menu_properties']))
        table.attach(self.use_menu_properties, 0, 2, 1, 2)

        framebox.pack_start(table)

    def save_change(self):
        self.settings['menu_path'] = self.menu_entry.get_text()
        self.settings['use_menu_properties'] = int(self.use_menu_properties.get_active())
        self.conf.plg_mgr.plugins[self.ind].restart()

# vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
