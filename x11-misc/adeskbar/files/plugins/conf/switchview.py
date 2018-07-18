# -*- coding: utf-8 -*-
#
# Adeskbar plugin to switch between two viewers.
# Copyright 2011 ANSSI
# Author: Mickaël Salaün <clipos@ssi.gouv.fr>
#
# All rights reserved

import gtk

settings = {
    # RM_H
    'viewer1_name': 'Niveau <b>diffusion restreinte</b>',
    'viewer1_img': 'level-dr',
    'viewer1_cmd': '/usr/local/bin/rm_h_session.sh',
    'viewer1_level': 2,
    'viewer1_class': '^Vncviewer$',
    'viewer1_title': '^Haut: Visionneuse RM_H$',
    'viewer1_start': '1',
    'viewer1_autostart': 'False',
    # RM_B
    'viewer2_name': 'Niveau <b>non protege</b>',
    'viewer2_img': 'level-np',
    'viewer2_cmd': '/usr/local/bin/rm_b_session.sh',
    'viewer2_level': 3,
    'viewer2_class': '^Vncviewer$',
    'viewer2_title': '^Bas: Visionneuse RM_B$',
    'viewer2_start': '0',
    'viewer2_autostart': 'True'
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

# vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
