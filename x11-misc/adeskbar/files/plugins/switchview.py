# -*- coding: utf-8 -*-
#
# Adeskbar plugin to switch between two viewers.
# Copyright 2011 ANSSI
# Author: Mickaël Salaün <clipos@ssi.gouv.fr>
#
# All rights reserved

import adesk.plugin as Plg
import adesk.core as Core
import os.path

from clip import viewmgr

LEVEL_COLORS = {
    'core': '#3e66ed',
    'unknown': '#000000',
    'rm_h': '#e42c33',
    'rm_b': '#3eed7c'
}

class Plugin(Plg.Plugin):
    def __init__(self, bar, settings):
        Plg.Plugin.__init__(self, bar, settings)
        self.settings = settings
        self.bar = bar
        self.level_focus = None
        self.level_rm = None
        self.level_props = {}
        views = {}
        
        if self.settings.has_key('core_color'):
            self.set_color('core', self.settings['core_color'])

        id = 1
        for view_id in xrange(1,3):
            view_str = str(view_id)
            flagfile = self.settings['viewer'+view_str+'_flag']
            if os.path.isfile(flagfile):
                level = self.settings['viewer'+view_str+'_level']
                self.level_props[level] = [self.settings['viewer'+view_str+'_name'], self.settings['viewer'+view_str+'_img']]
                try:
                    autostart = self.settings['viewer'+view_str+'_autostart']
                    if autostart.lower() == "yes": 
                        autostart = True
                    elif autostart.lower() == "no":
                        autostart = False
                    else:
                        raise RuntimeError # Invalid parameter
                except KeyError:
                    autostart = (id == 1)

                if self.settings.has_key('viewer'+view_str+'_color'):
                    color = self.settings['viewer'+view_str+'_color']
                    self.set_color(level, color)

                views[id] = viewmgr.ViewStruct(self.settings['viewer'+view_str+'_cmd'], level, self.settings['viewer'+view_str+'_class'], self.settings['viewer'+view_str+'_title'], autostart)
                id += 1
        if (id == 1):
            raise RuntimeError # No RM jails 
        elif (id == 2):
            self.sw = viewmgr.SwitchView(self.handler_switch_focus, self.handler_switch_rm, viewer1=views[1])
        else:
            self.sw = viewmgr.SwitchView(self.handler_switch_focus, self.handler_switch_rm, viewer1=views[1], viewer2=views[2])
        self.restart()

    #def on_init(self):
        #handler_switch_rm(self.sw.level):

    def restart(self):
        self.resize()

    def handler_switch_rm(self, level):
        self.set_tooltip(self.level_props[level][0])
        self.set_icon(self.level_props[level][1])

    def handler_switch_focus(self, level):
        color = LEVEL_COLORS[level]
        self.bar.cfg['bg_color_rgb'] = Core.hex2rgb(color)
        self.bar.draw_bg()
        self.bar.update()

    def set_color(self, level, color):
        """color is an HTML color and can be in the form #xxxxxx or "xxxxxx"."""
        import re
        color_hex_filter="^[0-9a-fA-F]{6}$"

        # color doesn't start with '#', insert it at the begining of the string
        if len(color) == 6 and re.match(color_hex_filter, color):
            color="#" + color
        # color starts with '#', the string format is already correct
        elif len(color) == 7 and color[0] == "#" and re.match(color_hex_filter, color[1:]):
            pass
        else:
            return

        if LEVEL_COLORS.has_key(level):
            LEVEL_COLORS[level] = color

    def stop(self):
        self.sw.stop()

    def onClick(self, widget, event):
        self.sw.switch()

# vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
