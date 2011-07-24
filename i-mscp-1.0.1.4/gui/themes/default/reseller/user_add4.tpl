<?xml version="1.0" encoding="{THEME_CHARSET}" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset={THEME_CHARSET}" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" />
		<title>{TR_ADD_USER_PAGE_TITLE}</title>
		<meta name="robots" content="nofollow, noindex" />
		<link href="{THEME_COLOR_PATH}/css/imscp.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="{THEME_COLOR_PATH}/js/imscp.js"></script>
		<script type="text/javascript" src="{THEME_COLOR_PATH}/js/jquery.js"></script>
		<script type="text/javascript" src="{THEME_COLOR_PATH}/js/jquery.imscpTooltips.js"></script>
		<!--[if IE 6]>
		<script type="text/javascript" src="{THEME_COLOR_PATH}/js/DD_belatedPNG_0.0.8a-min.js"></script>
		<script type="text/javascript">
			DD_belatedPNG.fix('*');
		</script>
		<![endif]-->
		<script language="JavaScript" type="text/JavaScript">
		/*<![CDATA[*/
			$(document).ready(function(){
				$('#dmn_help').iMSCPtooltips({msg:"{TR_DMN_HELP}"});
				$('input[name=ndomain_name]').blur(function(){
					dmnName = $('#ndomain_name').val();
					// Configure the request for encode_idna request
					$.ajaxSetup({
					url: $(location).attr('pathname'),
						type:'POST',
						data: 'domain=' + dmnName + '&uaction=toASCII',
						datatype: 'text',
						beforeSend: function(xhr){xhr.setRequestHeader('Accept','text/plain');},
						success: function(r){$('#ndomain_mpoint').val(r);},
						error: iMSCPajxError
					});
					$.ajax();
				});			
			});
			function setForwardReadonly(obj){
				if(obj.value == 1) {
					document.forms[0].elements['forward'].readOnly = false;
					document.forms[0].elements['forward_prefix'].disabled = false;
				} else {
					document.forms[0].elements['forward'].readOnly = true;
					document.forms[0].elements['forward'].value = '';
					document.forms[0].elements['forward_prefix'].disabled = true;
				}
			}
		/* ]]> */
		</script>
	</head>

	<body>

		<div class="header">
			{MAIN_MENU}

			<div class="logo">
				<img src="{ISP_LOGO}" alt="i-MSCP logo" />
			</div>
		</div>

		<div class="location">
			<div class="location-area icons-left">
				<h1 class="manage_users">{TR_MENU_MANAGE_USERS}</h1>
			</div>
			<ul class="location-menu">
				<!-- <li><a class="help" href="#">Help</a></li> -->
                <!-- BDP: logged_from -->
				<li><a class="backadmin" href="change_user_interface.php?action=go_back">{YOU_ARE_LOGGED_AS}</a></li>
                <!-- EDP: logged_from -->
				<li><a class="logout" href="../index.php?logout">{TR_MENU_LOGOUT}</a></li>
			</ul>
			<ul class="path">
				<li><a href="users.php">{TR_MENU_MANAGE_USERS}</a></li>
				<li><a href="user_add1.php">{TR_ADD_USER}</a></li>
				<li>{TR_ADD_ALIAS}</li>
			</ul>
		</div>

		<div class="left_menu">
			{MENU}
		</div>

		<div class="body">
			<h2 class="general"><span>{TR_ADD_USER}</span></h2>

			<!-- BDP: page_message -->
			<div class="{MESSAGE_CLS}">{MESSAGE}</div>
			<!-- EDP: page_message -->

			<!-- BDP: add_form -->
			<form name="add_alias_frm" method="post" action="user_add4.php">
				<!-- BDP: alias_list -->
					<table>
						<thead>
							<tr>
								<th>{TR_DOMAIN_ALIAS}</th>
								<th>{TR_FORWARD}</th>
								<th>{TR_STATUS}</th>
							</tr>
						</thead>
						<tbody>
							<!-- BDP: alias_entry -->
								<tr>
									<td>{DOMAIN_ALIAS}</td>
									<td>{FORWARD_URL}</td>
									<td>{STATUS}</td>
								</tr>
							<!-- EDP: alias_entry -->
						</tbody>
					</table>
					<br />
				<!-- EDP: alias_list -->
				<table>
					<thead>
						<tr>
							<th colspan="2">{TR_ADD_ALIAS}</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>
								<label for="ndomain_name">{TR_DOMAIN_NAME}</label><span class="icon i_help" id="dmn_help">Help</span>
							</td>
							<td><input id="ndomain_name" name="ndomain_name" type="text" value="{DOMAIN}" /></td>
						</tr>
						<tr>
							<td><label for="ndomain_mpoint">{TR_MOUNT_POINT}</label></td>
							<td><input id="ndomain_mpoint" name="ndomain_mpoint" type="text" value='{MP}' /></td>
						</tr>
						<tr>
							<td>{TR_ENABLE_FWD}</td>
							<td>
								<input type="radio" name="status" id="status_enable"{CHECK_EN} value="1" onChange="setForwardReadonly(this);" /><label for="status_enable">{TR_ENABLE}</label><br />
								<input type="radio" name="status" id="status_disable"{CHECK_DIS} value="0" onChange="setForwardReadonly(this);" /><label for="status_disable">{TR_DISABLE}</label>
							</td>
						</tr>
						<tr>
							<td>
								<label for="forward">{TR_FORWARD}</label>
							</td>
							<td>
								<select name="forward_prefix" style="vertical-align:middle"{DISABLE_FORWARD}>
									<option value="{TR_PREFIX_HTTP}"{HTTP_YES}>{TR_PREFIX_HTTP}</option>
									<option value="{TR_PREFIX_HTTPS}"{HTTPS_YES}>{TR_PREFIX_HTTPS}</option>
									<option value="{TR_PREFIX_FTP}"{FTP_YES}>{TR_PREFIX_FTP}</option>
								</select>
								<input name="forward" type="text" class="textinput" id="forward" value="{FORWARD}"{READONLY_FORWARD} />
							</td>
						</tr>
					</tbody>
				</table>

				<div class="buttons">
					<input name="Submit" type="submit" value="{TR_ADD}" />
					<input name="Button" type="button" onclick="MM_goToURL('parent','users.php');return document.MM_returnValue" value="{TR_GO_USERS}" />
				</div>
				<input type="hidden" name="uaction" value="add_alias" />
			</form>
			<!-- EDP: add_form -->
		</div>
		<div class="footer">
			i-MSCP {VERSION}<br />build: {BUILDDATE}<br />Codename: {CODENAME}
		</div>

	</body>
</html>