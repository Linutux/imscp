<?php
/**
 * i-MSCP a internet Multi Server Control Panel
 *
 * @copyright 	2001-2006 by moleSoftware GmbH
 * @copyright 	2006-2010 by ispCP | http://isp-control.net
 * @copyright 	2010 by i-MSCP | http://i-mscp.net
 * @version 	SVN: $Id$
 * @link 		http://i-mscp.net
 * @author 		ispCP Team
 * @author 		i-MSCP Team
 *
 * @license
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is "VHCS - Virtual Hosting Control System".
 *
 * The Initial Developer of the Original Code is moleSoftware GmbH.
 * Portions created by Initial Developer are Copyright (C) 2001-2006
 * by moleSoftware GmbH. All Rights Reserved.
 * Portions created by the ispCP Team are Copyright (C) 2006-2010 by
 * isp Control Panel. All Rights Reserved.
 * Portions created by the i-MSCP Team are Copyright (C) 2010 by
 * i-MSCP a internet Multi Server Control Panel. All Rights Reserved.
 */

require 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptStart);

check_login(__FILE__);

$cfg = iMSCP_Registry::get('config');

$tpl = new iMSCP_pTemplate();
$tpl->define_dynamic('page', $cfg->CLIENT_TEMPLATE_PATH . '/mail_edit.tpl');
$tpl->define_dynamic('page_message', 'page');
$tpl->define_dynamic('logged_from', 'page');
$tpl->define_dynamic('normal_mail', 'page');
$tpl->define_dynamic('forward_mail', 'page');

// page functions

function edit_mail_account($tpl) {

	$cfg = iMSCP_Registry::get('config');

	if (!isset($_GET['id']) || $_GET['id'] === '' || !is_numeric($_GET['id'])) {
		set_page_message(tr('Email account not found!'), 'error');
		redirectTo('mail_accounts.php');
	} else {
		$mail_id = $_GET['id'];
	}

	$dmn_name = $_SESSION['user_logged'];

	$query = "
		SELECT
			t1.*, t2.`domain_id`, t2.`domain_name`
		FROM
			`mail_users` AS t1, `domain` AS t2
		WHERE
			t1.`mail_id` = ?
		AND
			t2.`domain_id` = t1.`domain_id`
		AND
			t2.`domain_name` = ?
	";

	$rs = exec_query($query, array($mail_id, $dmn_name));

	if ($rs->recordCount() == 0) {
		set_page_message(tr('User does not exist or you do not have permission to access this interface!'), 'error');
		redirectTo('mail_accounts.php');
	} else {
		$mail_acc = $rs->fields['mail_acc'];
		$domain_id = $rs->fields['domain_id'];
		$mail_type_list = $rs->fields['mail_type'];
		$mail_forward = $rs->fields['mail_forward'];
		$sub_id = $rs->fields['sub_id'];

		foreach (explode(',', $mail_type_list) as $mail_type) {
			if ($mail_type == MT_NORMAL_MAIL) {
				$mtype[] = 1;
				$res1 = exec_query("SELECT `domain_name` FROM `domain` WHERE `domain_id` = ?", $domain_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $tmp1['domain_name'];
			} else if ($mail_type == MT_NORMAL_FORWARD) {
				$mtype[] = 4;
				$res1 = exec_query("SELECT `domain_name` FROM `domain` WHERE `domain_id` = ?", $domain_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $tmp1['domain_name'];
			} else if ($mail_type == MT_ALIAS_MAIL) {
				$mtype[] = 2;
				$res1 = exec_query("SELECT `alias_name` FROM `domain_aliasses` WHERE `alias_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $tmp1['alias_name'];
			} else if ($mail_type == MT_ALIAS_FORWARD) {
				$mtype[] = 5;
				$res1 = exec_query("SELECT `alias_name` FROM `domain_aliasses` WHERE `alias_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow();
				$maildomain = $tmp1['alias_name'];
			} else if ($mail_type == MT_SUBDOM_MAIL) {
				$mtype[] = 3;
				$res1 = exec_query("SELECT `subdomain_name` FROM `subdomain` WHERE `subdomain_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow();
				$maildomain = $tmp1['subdomain_name'];
				$res1 = exec_query("SELECT `domain_name` FROM `domain` WHERE `domain_id` = ?", $domain_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $maildomain . "." . $tmp1['domain_name'];
			} else if ($mail_type == MT_SUBDOM_FORWARD) {
				$mtype[] = 6;
				$res1 = exec_query("SELECT `subdomain_name` FROM `subdomain` WHERE `subdomain_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow();
				$maildomain = $tmp1['subdomain_name'];
				$res1 = exec_query("SELECT `domain_name` FROM `domain` WHERE `domain_id` = ?", $domain_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $maildomain . "." . $tmp1['domain_name'];
			} else if ($mail_type == MT_ALSSUB_MAIL) {
				$mtype[] = 7;
				$res1 = exec_query("SELECT `subdomain_alias_name`, `alias_id` FROM `subdomain_alias` WHERE `subdomain_alias_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow();
				$maildomain = $tmp1['subdomain_alias_name'];
				$alias_id = $tmp1['alias_id'];
				$res1 = exec_query("SELECT `alias_name` FROM `domain_aliasses` WHERE `alias_id` = ?", $alias_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $maildomain . "." . $tmp1['alias_name'];
			} else if ($mail_type == MT_ALSSUB_FORWARD) {
				$mtype[] = 8;
				$res1 = exec_query("SELECT `subdomain_alias_name`, `alias_id` FROM `subdomain_alias` WHERE `subdomain_alias_id` = ?", $sub_id);
				$tmp1 = $res1->fetchRow();
				$maildomain = $tmp1['subdomain_alias_name'];
				$alias_id = $tmp1['alias_id'];
				$res1 = exec_query("SELECT `alias_name` FROM `domain_aliasses` WHERE `alias_id` = ?", $alias_id);
				$tmp1 = $res1->fetchRow(0);
				$maildomain = $maildomain . "." . $tmp1['alias_name'];
			}
		}

		if (isset($_POST['forward_list'])) {
			$mail_forward = clean_input($_POST['forward_list']);
		}
		$mail_acc = decode_idna($mail_acc);
		$maildomain = decode_idna($maildomain);
		$tpl->assign(
			array(
				'EMAIL_ACCOUNT'	=> tohtml($mail_acc . "@" . $maildomain),
				'FORWARD_LIST'	=> str_replace(',', "\n", tohtml($mail_forward)),
				'MTYPE'			=> implode(',', $mtype),
				'MAIL_TYPE'		=> $mail_type_list,
				'MAIL_ID'		=> $mail_id
			)
		);

		if (($mail_forward !== '_no_') && (count($mtype) > 1)) {
			$tpl->assign(
				array(
					'ACTION'				=> 'update_pass,update_forward',
					'FORWARD_MAIL'			=> '',
					'FORWARD_MAIL_CHECKED'	=> $cfg->HTML_CHECKED,
					'FORWARD_LIST_DISABLED'	=> 'false'
				)
			);
			$tpl->parse('NORMAL_MAIL', '.normal_mail');
		} else if ($mail_forward === '_no_') {
			$tpl->assign(
				array(
					'ACTION'				=> 'update_pass',
					'FORWARD_MAIL'			=> '',
					'FORWARD_MAIL_CHECKED'	=> '',
					'FORWARD_LIST'			=> '',
					'FORWARD_LIST_DISABLED'	=> 'true'
				)
			);
			$tpl->parse('NORMAL_MAIL', '.normal_mail');
		} else {
			$tpl->assign(
				array(
					'ACTION'				=> 'update_forward',
					'NORMAL_MAIL'			=> '',
					'FORWARD_LIST_DISABLED'	=> 'false'
				)
			);
			$tpl->parse('FORWARD_MAIL', '.forward_mail');
		}
	}
}

function update_email_pass() {

	$cfg = iMSCP_Registry::get('config');

	if (!isset($_POST['uaction'])) {
		return false;
	}
	if (preg_match('/update_pass/', $_POST['uaction']) == 0) {
		return true;
	}
	if (preg_match('/update_forward/', $_POST['uaction']) == 1 || isset($_POST['mail_forward'])) {
		// The user only wants to update the forward list, not the password
		if ($_POST['pass'] === '' && $_POST['pass_rep'] === '') {
			return true;
		}
	}

	$pass = clean_input($_POST['pass']);
	$pass_rep = clean_input($_POST['pass_rep']);
	$mail_id = $_GET['id'];
	$mail_account = clean_input($_POST['mail_account']);

	if (trim($pass) === '' || trim($pass_rep) === '' || $mail_id === '' || !is_numeric($mail_id)) {
		set_page_message(tr('Password data is missing!'), 'error');
		return false;
	} else if ($pass !== $pass_rep) {
		set_page_message(tr('Entered passwords differ!'), 'error');
		return false;
	} else if (!chk_password($pass, 50, "/[`\xb4'\"\\\\\x01-\x1f\015\012|<>^$]/i")) { // Not permitted chars
		if ($cfg->PASSWD_STRONG) {
			set_page_message(sprintf(tr('The password must be at least %s long and contain letters and numbers to be valid.'), $cfg->PASSWD_CHARS), 'error');
		} else {
			set_page_message(sprintf(tr('Password data is shorter than %s signs or includes not permitted signs!'), $cfg->PASSWD_CHARS), 'error');
		}
		return false;
	} else {
		$status = $cfg->ITEM_CHANGE_STATUS;
		$query = "UPDATE `mail_users` SET `mail_pass` = ?, `status` = ? WHERE `mail_id` = ?";
		exec_query($query, array($pass, $status, $mail_id));
		write_log($_SESSION['user_logged'] . ": change mail account password: $mail_account", E_USER_NOTICE);
		return true;
	}
}

function update_email_forward($tpl) {

	$cfg = iMSCP_Registry::get('config');

	if (!isset($_POST['uaction'])) {
		return false;
	}
	if (preg_match('/update_forward/', $_POST['uaction']) == 0
		&& !isset($_POST['mail_forward'])) {
		return true;
	}

	$mail_account = $_POST['mail_account'];
	$mail_id = $_GET['id'];
	$forward_list = clean_input($_POST['forward_list']);
	$mail_accs = array();

	if (isset($_POST['mail_forward'])
		|| $_POST['uaction'] == 'update_forward') {
		$faray = preg_split ('/[\n\s,]+/', $forward_list);

		foreach ($faray as $value) {
			$value = trim($value);
			if (!chk_email($value) && $value !== '') {
				// @todo ERROR .. strange :) not email in this line - warning
				set_page_message(tr("Mail forward list error!"), 'error');
				return false;
			} else if ($value === '') {
				set_page_message(tr("Mail forward list error!"), 'error');
				return false;
			}
			$mail_accs[] = $value;
		}

		$forward_list = implode(',', $mail_accs);

		// Check if the mail type doesn't contain xxx_forward and append it
		if (preg_match('/_forward/', $_POST['mail_type']) == 0) {
			// Get mail account type and append the corresponding xxx_forward
			if ($_POST['mail_type'] == MT_NORMAL_MAIL) {
				$mail_type = $_POST['mail_type'] . ',' . MT_NORMAL_FORWARD;
			} else if ($_POST['mail_type'] == MT_ALIAS_MAIL) {
				$mail_type = $_POST['mail_type'] . ',' . MT_ALIAS_FORWARD;
			} else if ($_POST['mail_type'] == MT_SUBDOM_MAIL) {
				$mail_type = $_POST['mail_type'] . ',' . MT_SUBDOM_FORWARD;
			} else if ($_POST['mail_type'] == MT_ALSSUB_MAIL) {
				$mail_type = $_POST['mail_type'] . ',' . MT_ALSSUB_FORWARD;
			}
		} else {
			// The mail type already contains xxx_forward, so we can use $_POST['mail_type']
			$mail_type = $_POST['mail_type'];
		}
	} else {
		$forward_list = '_no_';
		// Check if mail type was a forward type and remove it
		if (preg_match('/_forward/', $_POST['mail_type']) == 1) {
			$mail_type = preg_replace('/,[a-z]+_forward$/', '', $_POST['mail_type']);
		}
	}

	$status = $cfg->ITEM_CHANGE_STATUS;

	$query = "UPDATE `mail_users` SET `mail_forward` = ?, `mail_type` = ?, `status` = ? WHERE `mail_id` = ?";
    exec_query($query, array($forward_list, $mail_type, $status, $mail_id));

	write_log($_SESSION['user_logged'] . ": change mail forward: $mail_account", E_USER_NOTICE);
	return true;
}

// end page functions.

$tpl->assign(
	array(
		'TR_CLIENT_EDIT_EMAIL_PAGE_TITLE'	=> tr('i-MSCP - Manage Mail and FTP / Edit mail account'),
		'THEME_COLOR_PATH'					=> "../themes/{$cfg->USER_INITIAL_THEME}",
		'THEME_CHARSET'						=> tr('encoding'),
		'ISP_LOGO'							=> layout_getUserLogo()
	)
);

// dynamic page data.

edit_mail_account($tpl);

if (update_email_pass() && update_email_forward($tpl)) {
	set_page_message(tr("Mail were updated successfully!"), 'success');
	send_request();
	redirectTo('mail_accounts.php');
}

// static page messages.

gen_client_mainmenu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/main_menu_email_accounts.tpl');
gen_client_menu($tpl, $cfg->CLIENT_TEMPLATE_PATH . '/menu_email_accounts.tpl');

gen_logged_from($tpl);

check_permissions($tpl);

$tpl->assign(
	array(
		'TR_EDIT_EMAIL_ACCOUNT'	=> tr('Edit email account'),
		'TR_SAVE'				=> tr('Save'),
		'TR_PASSWORD'			=> tr('Password'),
		'TR_PASSWORD_REPEAT'	=> tr('Repeat password'),
		'TR_FORWARD_MAIL'		=> tr('Forward mail'),
		'TR_FORWARD_TO'			=> tr('Forward to'),
		'TR_FWD_HELP'			=> tr("Separate multiple email addresses with a line-break."),
		'TR_EDIT'				=> tr('Edit')
	)
);

generatePageMessage($tpl);
$tpl->parse('PAGE', 'page');

iMSCP_Events_Manager::getInstance()->dispatch(
    iMSCP_Events::onClientScriptEnd, new iMSCP_Events_Response($tpl));

$tpl->prnt();

unsetMessages();