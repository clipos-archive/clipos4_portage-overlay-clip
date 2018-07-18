# -*- coding: utf-8 -*-
#
# Adeskbar plugin to create custom dynamic menu.
# Copyright 2011 ANSSI
# Author: Mickaël Salaün <clipos@ssi.gouv.fr>
#
# Distributed under the terms of the GNU General Public License v2

import gtk
import gmenu
import os

import adesk.plugin as Plg
import adesk.core as Core
import adesk.ui as UI

# lazy import...
# TODO: fix print path
import menu as plugin_menu

import pyinotify
NOTIFY = True

import gobject
gobject.threads_init()
import threading

import signal
import os
import adesk.bar as Bar
from subprocess import Popen

from xdg.DesktopEntry import DesktopEntry

PREFIX_USR = '/usr'
PREFIX_ROOT = ''

XDIALOG_PATH = PREFIX_USR + '/bin/Xdialog'
NOTIFY_PATH = PREFIX_USR + '/bin/notify-send'
ICONS_DIR = PREFIX_USR + '/share/icons/'

class CmdWrap(object):
    def __init__(self):
        self.cmds = {
                'quit':self.cmd_quit,
                'halt':self.cmd_halt,
                'reboot':self.cmd_reboot
                }

    def _confirm(self, title, msg):
        dialog = Popen([XDIALOG_PATH, '--title', title, '--yesno', msg, '0', '0'])
        if dialog.wait() == 0:
            return True
        return False

    def _exit(self, ret):
        Bar.RETCODE = ret
        os.kill(os.getpid(), signal.SIGTERM)

    def cmd_quit(self, argv=None):
        if self._confirm('Déconnexion', 'Confirmez-vous la déconnexion ?'):
            self._exit(0)

    def cmd_halt(self, argv=None):
        if self._confirm('Arrêt', 'Confirmez-vous l\'arrêt du système ?'):
            self._exit(101)

    def cmd_reboot(self, argv=None):
        if self._confirm('Redémarrage', 'Confirmez-vous le redémarrage du système ?'):
            self._exit(100)

    def run(self, cmd, with_term):
        assert type(cmd) == str
        if len(cmd) > 0 and cmd[0] == '!':
            try:
                cmd,argv = cmd[1:].split(' ', 1)
            except:
                cmd = cmd[1:]
                argv = None
            if cmd in self.cmds:
                self.cmds[cmd](argv)
            else:
                Core.logINFO('Command "{0}" not implemented.'.format(cmd))
        else:
            if with_term:
                cmd = 'x-terminal-emulator -e {0}'.format(cmd)
            Core.launch_command(cmd)

class EventHandler(pyinotify.ProcessEvent):
    def __init__(self, mensel):
        self.mensel = mensel
        self.timer = None
        self.lock_timer = threading.Lock()

    def process_default(self, event):
        self.set_timer()

    def set_timer(self):
        if not self.lock_timer.acquire(False):
            return
        if not self.timer == None:
            gobject.source_remove(self.timer)
        # Need enough time to update !
        self.timer = gobject.timeout_add(1500, self.timeout)

    def timeout(self):
        self.mensel.update_icon()
        self.timer = None
        self.lock_timer.release()
        return False

class MenuSelect(UI.Menu):
    def __init__(self, callback, menu_path):
        self.callback = callback
        self.menu = gtk.Menu()
        self.path = menu_path

        self.tree = gmenu.lookup_tree(self.path)
        if self.tree.root:
            self.add_to_menu(self.tree)

    def __del__(self):
        self.menu.destroy()

class Plugin(plugin_menu.Plugin):
    def __init__(self, bar, settings):
        Plg.Plugin.__init__(self, bar, settings)
        self.settings = settings
        self.bar = bar
        self.menu_empty = True
        self.menu = None
        self.cmdwrap = CmdWrap()
        self.lock_icon = threading.Lock()
        self.lock_menu = threading.Lock()
        self.usermsg = UserMsg()

    def on_init(self):
        self.restart()

    def stop(self):
        try:
            self.notifier.stop()
            del self.msg
        except:
            pass

    def launch_app(self, widget, menu_item):
        # Strip last part of path if it contains %<a-Z>
        command = menu_item.exec_info.split('%')[0]
        command = self.cmdwrap.run(command, menu_item.launch_in_terminal)

    def reload(self):
        self.menu_path = str(self.settings['menu_path'])
        self.use_menu_properties = int(self.settings['use_menu_properties']) == 1

    def restart(self):
        self.stop()
        self.reload()
        self.update_menu()
        self.update_icon()
        self.wm = pyinotify.WatchManager()
        handler = EventHandler(self)
        self.notifier = pyinotify.ThreadedNotifier(self.wm, handler)
        mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE | pyinotify.IN_MODIFY
        path = self.menu.tree.root.get_desktop_file_path()
        if path:
            self.wdd = self.wm.add_watch(os.path.dirname(path), mask, rec=True)
        self.notifier.start()

    def onClick(self, widget, event):
        self.update_menu()
        if not self.menu_empty:
            super(self.__class__, self).onClick(widget, event)

    def update_menu(self):
        self.lock_menu.acquire()
        if not self.is_visible:
            del self.menu
            self.menu = MenuSelect(self.launch_app, self.menu_path)
            self.menu.menu.connect('deactivate', self.menu_deactivate)
        self.lock_menu.release()

    def update_icon(self):
        self.lock_icon.acquire()
        menu_root = self.menu.tree.root
        assert(menu_root)
        assert(menu_root.get_type() == gmenu.TYPE_DIRECTORY)

        if self.use_menu_properties:
            self.set_icon(menu_root.get_icon())
            comment = menu_root.get_comment()
            if comment == None:
                comment = ''
            self.usermsg.parse_xdg(menu_root.get_desktop_file_path())
            self.tooltip = '<b>{0}</b>\n\n{1}'.format(menu_root.get_name(), comment).strip()
            if self.focus:
                self.set_tooltip(self.tooltip)
        else:
            self.set_tooltip(self.tooltip)
            self.set_icon(None)
        if len(menu_root.contents) == 0:
            self.menu_empty = True
            self.can_zoom = False
        else:
            self.menu_empty = False
            self.can_zoom = True
        self.lock_icon.release()

class UserMsg(object):
    icons = {'info':ICONS_DIR + 'dialog-information.png', 'warning':ICONS_DIR + 'dialog-warning.png', 'error':ICONS_DIR + 'dialog-error.png'}
    urgencies = {'info':'low', 'warning':'normal', 'error':'critical'}
    sleeps = {'info':5000, 'warning':5000, 'error':15000}

    def __init__(self):
        self._popup_exe = None
        self._notify_exe = None
        self.cache = {}

    def __del__(self):
        if self._popup_exe != None:
            self._popup_exe.kill()
        if self._notify_exe != None:
            self._notify_exe.kill()

    def parse_xdg(self, path):
        de = DesktopEntry(path)
        # type: popup, notify
        msg_type = de.get('X-CLIP-Msg-Type')
        # mode: info, warning, error
        msg_mode = de.get('X-CLIP-Msg-Mode')
        # content: user message
        msg_cont = de.get('X-CLIP-Msg-Content')
        cache = {'type':msg_type, 'mode':msg_mode, 'cont':msg_cont}
        if self.cache != cache:
            self.cache = cache
            if len(msg_mode) > 0 and len(msg_type) > 0 and len(msg_cont) > 0:
                if msg_type == 'popup':
                    self.popup(de.getName(), msg_cont, msg_mode)
                elif msg_type == 'notify':
                    self.notify(de.getName(), msg_cont, msg_mode)

    def popup(self, title, msg, status='warning'):
        if self._popup_exe == None or self._popup_exe.poll() != None:
            if status in self.icons.keys():
                self._popup_exe = Popen([XDIALOG_PATH, '--icon', self.icons[status], '--title', title, '--msgbox', msg, '0', '0'])

    def notify(self, title, msg, status='info'):
        if self._notify_exe == None or self._notify_exe.poll() != None:
            if status in self.icons.keys():
                self._notify_exe = Popen([NOTIFY_PATH, '-u', self.urgencies[status], '-t', str(self.sleeps[status]), '-i', self.icons[status], title, msg])

# vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
