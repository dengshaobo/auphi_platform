<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="org.quartz.Trigger" %>
<%@ page import="com.auphi.ktrl.util.*" %>
<%@ page import="com.auphi.ktrl.engine.*" %>
<%@ page import="com.auphi.ktrl.schedule.bean.*" %>
<%@ page import="com.auphi.ktrl.schedule.util.*" %>
<%@ page import="com.auphi.ktrl.ha.bean.*" %>
<%@ page import="com.auphi.ktrl.i18n.Messages" %>
<%@ page import="com.auphi.ktrl.system.user.bean.UserBean" %>
<%@ page import="com.auphi.ktrl.system.user.util.UserUtil" %>
<%@ page import="com.auphi.ktrl.system.priviledge.bean.PriviledgeType" %>

<%
	String user_id = session.getAttribute("user_id")==null?"":session.getAttribute("user_id").toString();
	UserBean userBeanSession = session.getAttribute("userBean")==null?new UserBean():(UserBean)session.getAttribute("userBean");

	PageList pageList = (PageList)request.getAttribute("pageList");
	List<ScheduleBean> listSchedule = (List<ScheduleBean>)pageList.getList();
	int pagenum = pageList.getPageInfo().getCurPage();
	
	List<UserBean> listUsers = (List<UserBean>)request.getAttribute("listUsers");
	List<HAClusterBean> listHACluster = (List<HAClusterBean>)request.getAttribute("listHACluster");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<%@ include file="../../common/extjs.jsp" %>
<script type="text/javascript" src="My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="admin/js/newDispatch.js"></script>
<script type="text/javascript" src="modules/dschedule/dschedule.js"></script>
<script type="text/javascript">
var win;
var winUsers;
var oldName = '';
Ext.onReady(function(){
	var tb = Ext.create('Ext.toolbar.Toolbar');
	tb.render('toolbar');
<%
	long priviledges = UserUtil.getPriviledgesOfUser(Integer.parseInt("".endsWith(user_id)?"0":user_id));
	boolean haveRun = PriviledgeType.hasPriviledge(priviledges, PriviledgeType.ExecuteFile);
	if(haveRun){
%>
	tb.add({text: '增加事件调度',iconCls: 'add',handler: onAddClick});
<%
	}
%>

	tb.add({text: '修改',iconCls: 'update',handler: onUpdate});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.Delete") %>',iconCls: 'delete',handler: onDeleteClick});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.CompleteDelete") %>',iconCls: 'completedelete',handler: onCompleteDeleteClick});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.Pause") %>',iconCls: 'pause',handler: onPauseClick});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.Resume") %>',iconCls: 'resume',handler: onResumeClick});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.Run") %>',iconCls: 'run',handler: onRunClick});
	tb.add({text: '<%=Messages.getString("Scheduler.Botton.Refresh") %>',iconCls: 'refresh',handler: onRefreshClick});
	tb.add({text: '依赖关系',iconCls: 'update',handler: onAddDependency});
	tb.doLayout();
	
	if(!win){
        win =  Ext.create('Ext.window.Window', {
        	contentEl: 'dlg',
        	title:'<%=Messages.getString("Scheduler.Dialog.Add.Title") %>',
        	width:320,
        	height:460,
        	autoHeight:true,
        	buttonAlign:'center',
        	closeAction:'hide',
	        buttons: [
	        	{text:'<%=Messages.getString("Scheduler.Dialog.Botton.Submit") %>',handler: function(){
	        			validateForm();	        			
	    	    	}
	        	},
	        	{text:'<%=Messages.getString("Scheduler.Dialog.Botton.Close") %>',handler: function(){win.hide();}}
	        ]
        });
    }
	
	if(!winUsers){
        winUsers =  Ext.create('Ext.window.Window', {
        	contentEl: 'dlg_users',
        	title:'<%=Messages.getString("Scheduler.Dialog.ErrorNotice.Title") %>',
        	width:207,
        	height:290,
        	autoHeight:true,
        	buttonAlign:'center',
        	closeAction:'hide',
	        buttons: [
	        	{text:'<%=Messages.getString("Scheduler.Dialog.Botton.Submit") %>',handler: function(){
	        			var selUsers = document.getElementById('selUsers');
	        			var errorNoticeUserName = document.getElementById('errorNoticeUserName');
	        			var errorNoticeUserId = document.getElementById('errorNoticeUserId');
	        			
	        			var sel_text = "";
	        			var sel_value = "";
	        			for(var i=0;i<selUsers.length;i++){     
	        		        if(selUsers.options[i].selected){
	        		        	if(sel_value.length == 0){
	        		        		sel_value = selUsers.options[i].value;
	        		        	}else {
	        		        		sel_value = sel_value + ',' + selUsers.options[i].value;
	        		        	}
	        		        	if(sel_text.length == 0){
	        		        		sel_text = selUsers.options[i].text;
	        		        	}else {
	        		        		sel_text = sel_text + ',' + selUsers.options[i].text;
	        		        	}
	        		        }  
	        		    }
	        			
	        			errorNoticeUserName.value = sel_text;
	        			errorNoticeUserId.value = sel_value;
	        			winUsers.hide();
	    	    	}
	        	},
	        	{text:'<%=Messages.getString("Scheduler.Dialog.Botton.Close") %>',handler: function(){winUsers.hide();}}
	        ]
        });
    }
	
	function onAddClick(){
		oldName = '';
       	document.getElementById('dataForm').reset();
       	enableEnddate('0');
       	document.getElementById('description').innerHTML = '';
       	changeCycle();
       	selVersion('', '', '', '');    	
       	document.getElementById('jobname_empty').style.display = 'none';
    	document.getElementById('jobname_error').style.display = 'none';
		document.getElementById('jobname_exist').style.display = 'none';
		document.getElementById('description_empty').style.display = 'none';
    	document.getElementById('connect_error').style.display = 'none';
    	document.getElementById('repempty_error').style.display = 'none';
		document.getElementById('file_empty').style.display = 'none';
		document.getElementById('starttime_empty').style.display = 'none';
    	document.getElementById('starttime_small').style.display = 'none';
    	document.getElementById('startdate_empty').style.display = 'none';
    	document.getElementById('startdate_small').style.display = 'none';
    	document.getElementById('cyclenum_empty').style.display = 'none';
    	document.getElementById('cyclenum_integer').style.display = 'none';
		document.getElementById('enddate_empty').style.display = 'none';
		document.getElementById('enddate_big').style.display = 'none';
       	win.setTitle('<%=Messages.getString("Scheduler.Dialog.Add.Title") %>');
        win.show();
  
    }
	
	function onUpdate(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.ChooseOne") %>');
						return false;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.Choose") %>');
			return false;
		}
		document.getElementById('checked_job').value = checked_job;
		oldName = checked_job;
		
		Ext.Ajax.request({
			url: 'schedule',
			method: 'POST',
			params: {
		        action: 'beforeUpdate',
		        jobname: checked_job
		    },
			success: function(transport) {
				var data = eval('('+transport.responseText+')');
				if(!data.item.jobName){
					updateJob();
					return false;
				}else {
					onUpdateClick();
					return false;
				}
			}
		});
	}
	
	function onUpdateClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.ChooseOne") %>');
						return false;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Edit.Choose") %>');
			return false;
		}
		document.getElementById('checked_job').value = checked_job;
		oldName = checked_job;
		
		document.getElementById('jobname_empty').style.display = 'none';
    	document.getElementById('jobname_error').style.display = 'none';
		document.getElementById('jobname_exist').style.display = 'none';
		document.getElementById('description_empty').style.display = 'none';
    	//document.getElementById('username_empty').style.display = 'none';
		//document.getElementById('password_empty').style.display = 'none';
		//document.getElementById('login_error').style.display = 'none';
    	document.getElementById('connect_error').style.display = 'none';
    	document.getElementById('repempty_error').style.display = 'none';
		document.getElementById('file_empty').style.display = 'none';
		document.getElementById('starttime_empty').style.display = 'none';
    	document.getElementById('starttime_small').style.display = 'none';
    	document.getElementById('starttime_empty').style.display = 'none';
    	document.getElementById('starttime_small').style.display = 'none';
    	document.getElementById('cyclenum_empty').style.display = 'none';
    	document.getElementById('cyclenum_integer').style.display = 'none';
		document.getElementById('enddate_empty').style.display = 'none';
		document.getElementById('enddate_big').style.display = 'none';
		
		Ext.Ajax.request({
			url: 'schedule',
			method: 'POST',
			params: {
		        action: 'beforeUpdate',
		        jobname: checked_job
		    },
			success: function(transport) {
				var data = eval('('+transport.responseText+')');
				document.getElementById('jobname').value = data.item.jobName;
				document.getElementById('description').value = data.item.description;
				document.getElementById('version').value = data.item.version;
		       	document.getElementById('file').value = data.item.actionRef;
		       	document.getElementById('filepath').value = data.item.actionPath;
		       	document.getElementById('filetype').value = data.item.fileType;
		       	document.getElementById('errorNoticeUserId').value = data.item.errorNoticeUserId==null?'':data.item.errorNoticeUserId;
		       	document.getElementById('errorNoticeUserName').value = data.item.errorNoticeUserName==null?'':data.item.errorNoticeUserName;
		       	if(data.item.fileType == '<%=KettleEngine.TYPE_TRANS %>'){
	            	document.getElementById('execTypeTd').innerHTML = '<select id="execType" name="execType" onchange="changeExecType(this.value, \'\', \'\');" style="width: 195px;">' + 
						'<option value="<%=KettleEngine.EXECTYPE_LOCAL %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.LocalExec") %></option>' + 
						'<option value="<%=KettleEngine.EXECTYPE_REMOTE %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.RemoteExec") %></option>' + 
						'<option value="<%=KettleEngine.EXECTYPE_CLUSTER %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.ClusterExec") %></option>' + 
						'<option value="<%=KettleEngine.EXECTYPE_HA %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.HAExec") %></option></select>';
	            }else if(data.item.fileType == '<%=KettleEngine.TYPE_JOB %>'){
	            	document.getElementById('execTypeTd').innerHTML = '<select id="execType" name="execType" onchange="changeExecType(this.value, \'\', \'\');" style="width: 195px;">' +
	            		'<option value="<%=KettleEngine.EXECTYPE_LOCAL %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.LocalExec") %></option>' +
						'<option value="<%=KettleEngine.EXECTYPE_REMOTE %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.RemoteExec") %></option>' + 
						'<option value="<%=KettleEngine.EXECTYPE_HA %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.HAExec") %></option></select>';
	            }
		       	selVersion(data.item.repName, data.item.execType, data.item.remoteServer, data.item.ha);
		       	document.getElementById('starttime').value = data.item.startTime;
		       	document.getElementById('startdate').value = data.item.startDate;
		       	document.getElementById('enddate').value = data.item.endDate;
				document.getElementById('cycle').value = data.item.cycle;
				document.getElementById('execType').value = data.item.execType;
				changeCycle();
				if(data.item.cycle != '1'){
					document.getElementById('cyclenum').value = data.item.cycleNum;
					//set enddate
					var enddateRadio = document.getElementsByName('enddateRadio');
					for(var i=0;i<enddateRadio.length;i++){
						if(enddateRadio[i].value == data.item.haveEndDate){
							enddateRadio[i].checked = true;
						}else {
							enddateRadio[i].checked = false;
						}
					}
					enableEnddate(data.item.haveEndDate);
					
					//set cycle mode
					if(data.item.cycle == '5'){//day trigger
						var daytyperadio = document.getElementsByName('daytyperadio');
						for(var i=0;i<daytyperadio.length;i++){
							if(daytyperadio[i].value == data.item.dayType){
								daytyperadio[i].checked = true;
							}else {
								daytyperadio[i].checked = false;
							}
						}
						changeDayType(data.item.dayType);
					}else if(data.item.cycle == '6'){//week trigger
						var weekcheckbox = document.getElementsByName('weekcheckbox');
						for(var i=0;i<weekcheckbox.length;i++){
							if(data.item.cycleNum.indexOf(weekcheckbox[i].value) >= 0){
								weekcheckbox[i].checked = true;
							}else {
								weekcheckbox[i].checked = false;
							}
						}
					}else if(data.item.cycle == '7'){//month trigger
						var monthtyperadio = document.getElementsByName('monthtyperadio');
						if(data.item.monthType == '0'){
							monthtyperadio[0].checked = true;
							monthtyperadio[1].checked = false;
						}else if(data.item.monthType == '1'){
							monthtyperadio[0].checked = false;
							monthtyperadio[1].checked = true;
							document.getElementById('weeknum').value = data.item.weekNum;
							document.getElementById('daynum').value = data.item.dayNum;
						}	
						changeMonthType(data.item.monthType);
					}else if(data.item.cycle == '8'){//year trigger
						var yeartyperadio = document.getElementsByName('yeartyperadio');
						if(data.item.yearType == '0'){
							yeartyperadio[0].checked = true;
							yeartyperadio[1].checked = false;
						}else if(data.item.yearType == '1'){
							yeartyperadio[0].checked = false;
							yeartyperadio[1].checked = true;
							document.getElementById('monthnum').value = data.item.monthNum;
							document.getElementById('weeknum').value = data.item.weekNum;
							document.getElementById('daynum').value = data.item.dayNum;
						}	
						changeYearType(data.item.yearType);
					}
				}
		  	}
		});
		
		win.setTitle('<%=Messages.getString("Scheduler.Dialog.Edit.Title") %>');
        win.show();
    }
	
	function onDeleteClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						checked_job = checked_job + ',' + checks[i].value;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Delete.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Delete.Choose") %>');
			return false;
		}
		
		
		Ext.MessageBox.confirm('<%=Messages.getString("Scheduler.Confirm.Delete.Title") %>', '<%=Messages.getString("Scheduler.Confirm.Delete.Message") %>', function (btn){
			if(btn=="yes"){
				document.getElementById('checked_job').value = checked_job;
				document.getElementById('listForm').action = 'dschedule?action=delete';
				document.getElementById('listForm').submit();
			}
		});
	}
	
	function onCompleteDeleteClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						checked_job = checked_job + ',' + checks[i].value;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.CompleteDelete.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.CompleteDelete.Choose") %>');
			return false;
		}
		
		
		Ext.MessageBox.confirm('<%=Messages.getString("Scheduler.Confirm.Delete.Title") %>', '<%=Messages.getString("Scheduler.Confirm.CompleteDelete.Message") %>', function (btn){
			if(btn=="yes"){
				document.getElementById('checked_job').value = checked_job;
				document.getElementById('listForm').action = 'dschedule?action=completedelete';
				document.getElementById('listForm').submit();
			}
		});
	}
	
	function onPauseClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						checked_job = checked_job + ',' + checks[i].value;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Pause.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Pause.Choose") %>');
			return false;
		}
		
		document.getElementById('checked_job').value = checked_job;
		document.getElementById('listForm').action = 'dschedule?action=pause&page=<%=pagenum %>';
		document.getElementById('listForm').submit();
	}
	
	function onResumeClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						checked_job = checked_job + ',' + checks[i].value;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Resume.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Resume.Choose") %>');
			return false;
		}
		
		document.getElementById('checked_job').value = checked_job;
		document.getElementById('listForm').action = 'dschedule?action=resume&page=<%=pagenum %>';
		document.getElementById('listForm').submit();
	}
	
	function onRunClick(){
		var checks = document.getElementsByName('check');
		var checked_job = '';
		var check_count = 0;
		if(checks.length){
			for(var i=0;i<checks.length;i++){
				if(checks[i].checked){
					check_count = check_count + 1;
					if(checked_job == ''){
						checked_job = checks[i].value;
					}else {
						checked_job = checked_job + ',' + checks[i].value;
					}
				}
			}
			if(check_count == 0){
				Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Run.Choose") %>');
				return false;
			}
		}else {
			Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Warnning.Run.Choose") %>');
			return false;
		}
		
		document.getElementById('checked_job').value = checked_job;
		document.getElementById('listForm').action = 'dschedule?action=run&page=<%=pagenum %>';
		document.getElementById('listForm').submit();
    }
	
	function onRefreshClick(){
		window.location.href = 'dschedule?action=list&page=<%=pagenum %>';
    }
});

function validateForm(){
	var jobname = document.getElementById('jobname').value.replace(/(^\s*)|(\s*$)/g, "");
	var description = document.getElementById('description').value;
	var file = document.getElementById('file').value;
	var starttime = document.getElementById('starttime').value;
	var cyclenum = document.getElementById('cyclenum');
	var startdate = document.getElementById('startdate').value;
	var enddate = document.getElementById('enddate').value;
	var execType = document.getElementById('execType').value;
	
	var success = true;
	
	if(jobname == ''){
		document.getElementById('jobname_empty').style.display = '';
		success = false;
	}else {
		document.getElementById('jobname_empty').style.display = 'none';
	}
	
	if(jobname.indexOf("\'")>0 || jobname.indexOf("\"")>0 || jobname.indexOf("<")>0 
	|| jobname.indexOf(">")>0 || jobname.indexOf(",")>0 || jobname.indexOf(".")>0){
		document.getElementById('jobname_error').style.display = '';
		success = false;
	}else {
		document.getElementById('jobname_error').style.display = 'none';
	}
	
	if(description == ''){
		document.getElementById('description_empty').style.display = '';
		success = false;
	}else {
		document.getElementById('description_empty').style.display = 'none';
	}
	
	/*
	if(file == ''){
		document.getElementById('file_empty').style.display = '';
		success = false;
	}else {
		document.getElementById('file_empty').style.display = 'none';
	}*/
	
	var cycle = document.getElementById("cycle").value;
	if(cycle == '2' || cycle == '3' || cycle == '4' || cycle == '5'){//validate input integer
		if(cycle != '5'){
			if(cyclenum.value != ''){
				if(!valiInteger(cyclenum.value)){
					document.getElementById('cyclenum_integer').style.display = '';
					success = false;
				}else {
					document.getElementById('cyclenum_integer').style.display = 'none';
				}
			}
		}else {//day tirgger
			var daytype = document.getElementById('daytype').value;
			if(cyclenum.value != ''){
				if(daytype == '0' && !valiInteger(cyclenum.value)){
					document.getElementById('cyclenum_integer').style.display = '';
					success = false;
				}else {
					document.getElementById('cyclenum_integer').style.display = 'none';
				}
			}
		}
	}else {
		document.getElementById('cyclenum_integer').style.display = 'none';
	}
	if(cycle != '1'){
		if(cycle == '5'){//day trigger
			var daytype = document.getElementById('daytype').value;
			if(daytype == '0'){
				if(cyclenum.value == ''){
					document.getElementById('cyclenum_empty').style.display = '';
					success = false;
				}else {
					document.getElementById('cyclenum_empty').style.display = 'none';
				}
			}else {
				document.getElementById('cyclenum_empty').style.display = 'none';
			}
		} else if(cycle == '7'){//month trigger
			var monthtype = document.getElementById('monthtype').value;
			if(monthtype == '0'){
				if(cyclenum.value == ''){
					document.getElementById('cyclenum_empty').style.display = '';
					success = false;
				}else {
					document.getElementById('cyclenum_empty').style.display = 'none';
				}
			}else {
				document.getElementById('cyclenum_empty').style.display = 'none';
			}
		} else if(cycle == '8'){//year trigger
			var yeartype = document.getElementById('yeartype').value;
			if(yeartype == '0'){
				if(cyclenum.value == ''){
					document.getElementById('cyclenum_empty').style.display = '';
					success = false;
				}else {
					document.getElementById('cyclenum_empty').style.display = 'none';
				}
			}else {
				document.getElementById('cyclenum_empty').style.display = 'none';
			}
		}else {//others
			if(cyclenum.value == ''){
				document.getElementById('cyclenum_empty').style.display = '';
				success = false;
			}else {
				document.getElementById('cyclenum_empty').style.display = 'none';
			}
		}
		
		var haveenddate = document.getElementById("haveenddate").value;
		
		if(haveenddate == '1'){
			if(enddate == ''){
				document.getElementById('enddate_empty').style.display = '';
				success = false;
			}else {
				document.getElementById('enddate_empty').style.display = 'none';
				var start_date = new Date(Date.parse(startdate.replace(/-/g,"/")));
				var end_date = new Date(Date.parse(enddate.replace(/-/g,"/")));
				if(start_date>end_date){
					document.getElementById('enddate_big').style.display = '';
					success = false;
				}else {
					document.getElementById('enddate_big').style.display = 'none';
				}
			}
		}else {
			document.getElementById('enddate_empty').style.display = 'none';
			document.getElementById('enddate_big').style.display = 'none';
		}
	}
	
	
	if(starttime == ''){
		document.getElementById('starttime_empty').style.display = '';
		success = false;
	}else {
		document.getElementById('starttime_empty').style.display = 'none';
	}
	
	if(startdate == ''){
		document.getElementById('startdate_empty').style.display = '';
		success = false;
	}else {
		document.getElementById('startdate_empty').style.display = 'none';
		var currentDate = new Date();
		var start_date = new Date(Date.parse(startdate.replace(/-/g,"/")));
		if(start_date < currentDate && start_date.toLocaleDateString() != currentDate.toLocaleDateString()){
			document.getElementById('startdate_small').style.display = '';
			document.getElementById('starttime_small').style.display = 'none';
			success = false;
		}else {
			if(starttime != ''){
				currentDate = new Date();
				var start_date = new Date(Date.parse(startdate.replace(/-/g,"/") + ' ' + starttime));
				if(start_date < currentDate){
					document.getElementById('starttime_small').style.display = '';
					success = false;
				}else {
					document.getElementById('starttime_small').style.display = 'none';
				}
			}else {
				document.getElementById('starttime_small').style.display = 'none';
			}
			document.getElementById('startdate_small').style.display = 'none';
		}
	}
	
	if(execType == '2'){
		var remoteServer = document.getElementById('remoteServer').value;
		if(remoteServer == ''){
			document.getElementById('remoteserver_error').style.display = '';
			success = false;
		}
	}
	
	var version = document.getElementById('version').value;
	var repository = document.getElementById('repository').value;
	
	if(success){
		Ext.Ajax.request({
			url: 'schedule',
			method: 'POST',
			params: {
		        action: 'checkRepLogin',
		        version: version,
		        repository: repository
		    },
			success: function(transport) {
				var res = transport.responseText;
			    if(res == '2'){//error connect to the repository
			    	document.getElementById('connect_error').style.display = '';
			    	document.getElementById('repempty_error').style.display = 'none';
			    }else if(res == '3'){
			    	document.getElementById('connect_error').style.display = 'none';
			    	document.getElementById('repempty_error').style.display = '';
			    }else if(res == '0'){//connect successful
			    	document.getElementById('connect_error').style.display = 'none';
			    	document.getElementById('repempty_error').style.display = 'none';
			    	if(jobname != ''){
			    		if(jobname != oldName){
			    			Ext.Ajax.request({
			    				url: 'schedule',
			    				method: 'POST',
			    				params: {
			    			        action: 'checkJobExist',
			    			        jobname: jobname
			    			    },
			    				success: function(transport) {
			    				    var res = transport.responseText;
			    				    if(res == 'true'){
			    				    	document.getElementById('jobname_exist').style.display = '';
			    				    	success = false;
			    				    }else {
			    				    	document.getElementById('jobname_exist').style.display = 'none';
			    				    }
			    				    
			    				    if(success){
			    				    	if(oldName == ''){
			    				    		Ext.getDom('dataForm').action = 'dschedule?action=add&page=<%=pagenum %>';
				    	    				Ext.getDom('dataForm').submit();
			    				    	}else {
			    				    		Ext.getDom('dataForm').action = 'dschedule?action=update&page=<%=pagenum %>&checked_job=' + encodeURI(oldName);
			    				    		oldName = '';
						    				Ext.getDom('dataForm').submit();
			    				    	}
			    	    			}else {
			    	    				return false;
			    	    			}
			    			  	}
			    			});
			    		}else {
			    			if(success){
			    				Ext.getDom('dataForm').action = 'dschedule?action=update&page=<%=pagenum %>&checked_job=' + encodeURI(oldName);
			    				oldName = '';
			    				Ext.getDom('dataForm').submit();
			    			}else {
			    				return false;
			    			}
			    		}
			    		
			    	}
			    }
		  	}
		});
	}else {
    	document.getElementById('connect_error').style.display = 'none';
    	document.getElementById('repempty_error').style.display = 'none';
		document.getElementById('jobname_exist').style.display = 'none';
	}
}

function valiInteger(cyclenum){
	var re = /^[1-9]\d*$/;
    if (!re.test(cyclenum)){
        return false;
    }else {
    	return true;
    }
}

function validateRep(){
	var valiRepSuccess = true;
	
	var version = document.getElementById('version').value;
	var repository = document.getElementById('repository').value;
	if(valiRepSuccess){
		Ext.Ajax.request({
			url: 'schedule',
			method: 'POST',
			params: {
		        action: 'checkRepLogin',
		        version: version,
		        repository: repository
		    },
			success: function(transport) {
			    var res = transport.responseText;
			    if(res == '2'){//error connect to the repository
			    	document.getElementById('connect_error').style.display = '';
			    	document.getElementById('repempty_error').style.display = 'none';
			    }else if(res == '3'){
			    	document.getElementById('connect_error').style.display = 'none';
			    	document.getElementById('repempty_error').style.display = '';
			    }else if(res == '0'){//connect successful
			    	document.getElementById('connect_error').style.display = 'none';
			    	document.getElementById('repempty_error').style.display = 'none';
			    	selRep();
			    }
		  	}
		});
	}
}

function checkAll(){
	var checkall = document.getElementById('checkall');
	var checks = document.getElementsByName('check');
	if(checkall.checked == 'true'){
		for(var i=0;i<checks.length;i++){
			if(checks[i].disabled){
				checks[i].checked = 'false';
			}else {
				checks[i].checked = 'true';
			}
		}
	}else {
		for(var i=0;i<checks.length;i++){
			if(!checks[i].disabled){
				checks[i].checked = !checks[i].checked;
			}
		}
	}
}

function changeCycle(){
	var cycle = document.getElementById("cycle").value;
	var cyclemode_td = document.getElementById("cyclemode_td");
	var enddate_td = document.getElementById("enddate_td");
	
	if(cycle == '1'){//run once
		cyclemode_td.style.display = 'none';
		enddate_td.style.display = 'none';
	}else {//cycle run 
		cyclemode_td.style.display = '';
		enddate_td.style.display = '';
		var cyclemode_span = document.getElementById('cyclemode_span');
		if(cycle == '2'){//second
			cyclemode_span.innerHTML = '<%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Every") %><input type="text" id="cyclenum" name="cyclenum" style="width: 50px;" maxlength="9"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Second.Time") %>';
		}else if(cycle == '3'){//minute
			cyclemode_span.innerHTML = '<%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Every") %><input type="text" id="cyclenum" name="cyclenum" style="width: 50px;" maxlength="7"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Minute") %>';
		}else if(cycle == '4'){//hour
			cyclemode_span.innerHTML = '<%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Every") %><input type="text" id="cyclenum" name="cyclenum" style="width: 50px;" maxlength="5"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Hour") %>';
		}else if(cycle == '5'){//day
			cyclemode_span.innerHTML = '<input type="radio" id="daytyperadio" name="daytyperadio" value="0" checked="checked" onchange="changeDayType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Every") %><input type="text" id="cyclenum" name="cyclenum" style="width: 50px;" maxlength="4"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Day") %>' + 
									   '<input type="radio" id="daytyperadio" name="daytyperadio" value="1" onchange="changeDayType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryWorkDay") %><input type="hidden" name="daytype" id="daytype" value="0">';
		}else if(cycle == '6'){//week
			cyclemode_span.innerHTML = '<input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="2" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Monday") %><input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="3" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Tuesday") %>' + 
			                           '<input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="4" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Wednesday") %><input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="5" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Thursday") %>' + 
									   '<input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="6" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Friday") %><input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="7" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Saturday") %>' + 
									   '<input type="checkbox" id="weekcheckbox" name="weekcheckbox" value="1" onchange="changeWeekDay();"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Sunday") %><input type="hidden" id="cyclenum" name="cyclenum">';
		}else if(cycle == '7'){//month
			cyclemode_span.innerHTML = '<input type="radio" id="monthtyperadio" name="monthtyperadio" value="0" checked="checked" onchange="changeMonthType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryMonth") %><select id="cyclenum" name="cyclenum">' + 
									   '<option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option>' +
									   '<option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option>' +
									   '<option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option><option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option>' +
									   '<option value="31">31</option><option value="L">L</option></select><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryMonth_Day") %><br>' + 
									   '<input type="radio" id="monthtyperadio" name="monthtyperadio" value="1" onchange="changeMonthType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryMonth") %><select id="weeknum" name="weeknum"><option value="1"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.First") %></option><option value="2"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Second.Number") %></option><option value="3"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Third") %></option><option value="4"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Fourth") %></option><option value="L"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Last") %></option></select>' +
									   '<select id="daynum" name="daynum"><option value="2"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Monday") %></option><option value="3"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Tuesday") %></option><option value="4"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Wednesday") %></option><option value="5"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Thursday") %></option><option value="6"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Friday") %></option><option value="7"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Saturday") %></option><option value="1"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Sunday") %></option></select><input type="hidden" name="monthtype" id="monthtype" value="0">';
			changeMonthType('0');
		}else if(cycle == '8'){//year
			cyclemode_span.innerHTML = '<input type="radio" id="yeartyperadio" name="yeartyperadio" value="0" checked="checked" onchange="changeYearType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryYear") %><input type="text" id="cyclenum" name="cyclenum" readonly="readonly" style="width: 50px" onclick="WdatePicker({dateFmt:\'MM-dd\'});"><br>' + 
									   '<input type="radio" id="yeartyperadio" name="yeartyperadio" value="1" onchange="changeYearType(this.value);"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.EveryYear") %><input type="text" name="monthnum" id="monthnum" onclick="WdatePicker({dateFmt:\'M\'});" readonly="readonly" style="width: 20px"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Month") %><select id="weeknum" name="weeknum" style="width: 65px;"><option value="1"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.First") %></option><option value="2"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Second.Number") %></option><option value="3"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Third") %></option><option value="4"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Fourth") %></option><option value="L"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Last") %></option></select>' +
									   '<select id="daynum" name="daynum" style="width: 60px;"><option value="2"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Monday") %></option><option value="3"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Tuesday") %></option><option value="4"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Wednesday") %></option><option value="5"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Thursday") %></option><option value="6"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Friday") %></option><option value="7"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Saturday") %></option><option value="1"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Sunday") %></option></select><input type="hidden" name="monthtype" id="monthtype" value="0"><input type="hidden" name="yeartype" id="yeartype" value="0">';
			changeYearType('0');
		}
	}
}

function enableEnddate(value){
	var enddate = document.getElementById("enddate");
	document.getElementById("haveenddate").value = value;
	
	if(value == '0'){
		enddate.disabled = 'disabled';
	}else if(value == '1'){
		enddate.disabled = '';
	}
}

function changeDayType(value){
	var cyclenum = document.getElementById("cyclenum");
	document.getElementById("daytype").value = value;
	
	if(value == '0'){
		cyclenum.disabled = '';
	}else if(value == '1'){
		cyclenum.disabled = 'disabled';
	}
}

function changeWeekDay(){
	var cyclenum = document.getElementById('cyclenum');
	var weekcheckbox = document.getElementsByName('weekcheckbox');
	for(var i=0;i<weekcheckbox.length;i++){
		if(weekcheckbox[i].checked){
			if(i == 0){
				cyclenum.value = weekcheckbox[i].value;
			}else {
				cyclenum.value = cyclenum.value + ',' + weekcheckbox[i].value;
			}
		}
	}
}

function changeMonthType(value){
	var cyclenum = document.getElementById("cyclenum");
	var weeknum = document.getElementById("weeknum");
	var daynum = document.getElementById("daynum");
	document.getElementById("monthtype").value = value;
	
	if(value == '0'){
		cyclenum.disabled = '';
		weeknum.disabled = 'disabled';
		daynum.disabled = 'disabled';
	}else if(value == '1'){
		cyclenum.disabled = 'disabled';
		weeknum.disabled = '';
		daynum.disabled = '';
	}
}

function changeYearType(value){
	var cyclenum = document.getElementById("cyclenum");
	var monthnum = document.getElementById("monthnum");
	var weeknum = document.getElementById("weeknum");
	var daynum = document.getElementById("daynum");
	document.getElementById("yeartype").value = value;
	
	if(value == '0'){
		cyclenum.disabled = '';
		monthnum.disabled = 'disabled';
		weeknum.disabled = 'disabled';
		daynum.disabled = 'disabled';
	}else if(value == '1'){
		cyclenum.disabled = 'disabled';
		monthnum.disabled = '';
		weeknum.disabled = '';
		daynum.disabled = '';
	}
}


function selFile(){
	validateRep();
}

function selUser(){
	var selUsers = document.getElementById('selUsers');
	var errorNoticeUserId = document.getElementById('errorNoticeUserId').value;
	var sel_userids = errorNoticeUserId.split(',');
	
	for(var i=0;i<sel_userids.length;i++){    
		for(var j=0;j<selUsers.options.length;j++){
			if(selUsers.options[j].value == sel_userids[i]){
	        	selUsers.options[j].selected = true;
	        	break;
	        }	
		}  
    }
	
	winUsers.show();
}

function selVersion(repName, execType, remoteServer, ha){
	Ext.Ajax.request({
		url: 'schedule',
		method: 'POST',
		params: {
	        action: 'getReps',
	        version: document.getElementById('version').value
	    },
		success: function(transport) {
		    var data = eval('('+transport.responseText+')');
		    var list = data.list.item;
		    var reps_select = '<select id="repository" name="repository" style="width: 195px;">';
		    if(list){
		    	if(list.length){
		    		for(var i=0;i<list.length;i++){
				    	reps_select = reps_select + '<option value="' + list[i].repositoryName + '">' + list[i].repositoryName + '</option>';
				    }
		    	}else {
		    		reps_select = reps_select + '<option value="' + list.repositoryName + '">' + list.repositoryName + '</option>';
		    	}
		    }
		    reps_select = reps_select + '</select>';
		    
		    
		    document.getElementById("rep_span").innerHTML = reps_select;
		    if( repName != ''){
		    	document.getElementById("repository").value = repName;
		    }
		    
			changeExecType(execType, remoteServer, ha);
	  	}
	});
}

function selRep(){
	//document.getElementById('repTree').innerHTML = '';
	var version = document.getElementById('version').value;
	var repository = document.getElementById('repository').value;
	//var username = document.getElementById('username').value;
	//var password = document.getElementById('password').value;
	
	var store = Ext.create('Ext.data.TreeStore', {
		autoLoad: false,
	    proxy: {
	    	type: 'ajax',
	    	reader: {
	    		type: 'json'
	    	},
	    	url: 'dschedule?action=getRepTree&version=' + version + '&repository=' + encodeURI(repository)
	    }
	});     
	
	var tree = Ext.create('Ext.tree.Panel',{
    	border: false,
        //width: 220,
	    //height: 220,
	    //autoScroll: true,
	    //containerScroll: true,
	    store: store,
	    //bodyStyle :"overflow-x:scroll;overflow-y:scroll",
	    rootVisible: false, 
	    listeners: {
	        'itemclick': function(tree,record,item,index,e,options){
	            if(record.isLeaf()){
	            	var index1 = record.get('text').indexOf('[');
	            	document.getElementById('file').value = record.get('text').substring(0,index1);
	            	var filetype = record.get('text').substring(index1 + 1,record.get('text').length - 1);
	            	document.getElementById('filetype').value = filetype;
		            var filePath = '';
		            while(true){
		            	record = record.parentNode;
		            	if(record.isRoot()){
		            		break;
		            	}else {
		            		if(record.get('text') != '/'){
		            			filePath = '/' + record.get('text') + filePath;
		            		}
		            	}
		            }
		            if(filePath == ''){
		            	filePath = '/';
		            }
		            document.getElementById('filepath').value = filePath;
		            
		            if(filetype == '<%=KettleEngine.TYPE_TRANS %>'){
		            	document.getElementById('execTypeTd').innerHTML = '<select id="execType" name="execType" onchange="changeExecType(this.value, \'\', \'\');" style="width: 195px;">' + 
							'<option value="<%=KettleEngine.EXECTYPE_LOCAL %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.LocalExec") %></option>' + 
							'<option value="<%=KettleEngine.EXECTYPE_REMOTE %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.RemoteExec") %></option>' + 
							'<option value="<%=KettleEngine.EXECTYPE_CLUSTER %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.ClusterExec") %></option>' + 
							'<option value="<%=KettleEngine.EXECTYPE_HA %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.HAExec") %></option></select>';
		            }else if(filetype == '<%=KettleEngine.TYPE_JOB %>'){
		            	document.getElementById('execTypeTd').innerHTML = '<select id="execType" name="execType" onchange="changeExecType(this.value, \'\', \'\');" style="width: 195px;">' +
		            		'<option value="<%=KettleEngine.EXECTYPE_LOCAL %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.LocalExec") %></option>' +
							'<option value="<%=KettleEngine.EXECTYPE_REMOTE %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.RemoteExec") %></option>' + 
							'<option value="<%=KettleEngine.EXECTYPE_HA %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.HAExec") %></option></select>';
		            }
		            
		            changeExecType('', '', '');
		            
		            winFile.hide();
	            }
	        }
	    }
    });
	
	tree.expand(true);
	
	var winFile = Ext.create('Ext.window.Window', {
        	contentEl: 'dlg_file',
        	title:'<%=Messages.getString("Scheduler.Dialog.File.Title") %>',
        	width:235,
        	height:290,
        	//autoHeight:true,
        	//autoScroll: true,
        	//scroll:true,
        	//containerScroll: true,
        	buttonAlign:'center',
        	closeAction:'hide',
        	layout:'fit',
        	items: tree
    });

	winFile.show();
}

function countlen(){ 
	var description = document.getElementById('description');
    if(description.value.length > 120){ 
    	description.value = description.value.substring(0,120);
    	Ext.MessageBox.alert('<%=Messages.getString("Scheduler.Warnning.Warn") %>','<%=Messages.getString("Scheduler.Dialog.Title.Description.Warn.Long") %>');
    } 

    return true; 
} 

function showMonitor(jobName){
	parent.toLoadurl('monitor?action=list&jobName=' + encodeURI(jobName),'monitor_main_' + jobName,'<%=Messages.getString("Default.Jsp.Menu.Monitor") + "_" %>' + jobName);
}

function changeExecType(execType, remoteServer, ha){
	var version = document.getElementById('version').value;
	var repository = document.getElementById('repository').value;
	if(execType == '<%=KettleEngine.EXECTYPE_REMOTE %>'){
		Ext.Ajax.request({
			url: 'schedule',
			method: 'POST',
			params: {
		        action: 'getRemoteServers',
		        version: version,
		        repository: repository
		    },
			success: function(transport) {
			    var serverSelect = transport.responseText;
			    document.getElementById('remoteServerTd').innerHTML = serverSelect;
			    document.getElementById('haTr').style.display = 'none';
			    document.getElementById('remoteServerTr').style.display = '';
			    if(remoteServer != ''){
			    	document.getElementById('remoteServer').value = remoteServer;
			    }
			    document.getElementById('remoteserver_error').style.display = 'none';
			}
		});
	}else if(execType == '<%=KettleEngine.EXECTYPE_HA %>'){
		document.getElementById('haTr').style.display = '';
	    document.getElementById('remoteServerTr').style.display = 'none';
	    if(ha != ''){
	    	document.getElementById('ha').value = ha;
	    }
	}else {
		document.getElementById('remoteServerTr').style.display = 'none';
		document.getElementById('haTr').style.display = 'none';
	}
}
</script>
</head>
<body onload="parent.iframeResize(this.frames.name);" onresize="parent.iframeResize(this.frames.name);">
	<div id="toolbar"></div>
	<form id="listForm" name="listForm" action="" method="post">
	<%=pageList.getPageInfo().getHtml("dschedule?action=list") %>
	<br />
	<input type="hidden" name="checked_job" id="checked_job">
	<table width="90%" align="center" id="the-table">
		<tr align="center" bgcolor="#ADD8E6" class="b_tr">
			<td><input type="checkbox" name="checkall" id="checkall" onclick="checkAll();" ><%=Messages.getString("Scheduler.Table.Column.Choose") %></td>
			<td><%=Messages.getString("Scheduler.Table.Column.Name") %></td>
			<!-- <td><%=Messages.getString("Scheduler.Table.Column.Group") %></td>-->
			<td><%=Messages.getString("Scheduler.Table.Column.Repository") %></td>
			<!-- <td><%=Messages.getString("Scheduler.Table.Column.Dependencies") %></td>-->
			<td><%=Messages.getString("Scheduler.Table.Column.Status") %></td>
			<td><%=Messages.getString("Scheduler.Table.Column.Description") %></td>
			<td><%=Messages.getString("Scheduler.Table.Column.NextFireTime") %></td>
			<td><%=Messages.getString("Scheduler.Table.Column.ErrorNotice") %></td>
		</tr>
<%
	for(ScheduleBean scheduleBean:listSchedule){
		String state = "";
		switch(scheduleBean.getTriggerState()){
		case Trigger.STATE_BLOCKED:
			state = Messages.getString("Scheduler.Status.Block");
			break;
		case Trigger.STATE_COMPLETE:
			state = Messages.getString("Scheduler.Status.Complete");
			break;
		case Trigger.STATE_ERROR:
			state = Messages.getString("Scheduler.Status.Error");
			break;
		case Trigger.STATE_NONE:
			state = Messages.getString("Scheduler.Status.None");
			break;
		case Trigger.STATE_NORMAL:
			state = Messages.getString("Scheduler.Status.Normal");
			break;
		case Trigger.STATE_PAUSED:
			state = Messages.getString("Scheduler.Status.Pause");
			break;
		}
		String path = "/".equals(scheduleBean.getActionPath())?scheduleBean.getActionPath():scheduleBean.getActionPath() + "/";
		String description = scheduleBean.getDescription()==null?"":scheduleBean.getDescription();
		String description_b = "";
		for(int i=0;i<description.length();i+=20){
			String temp = description.substring(i,i+20>description.length()?description.length():i+20)+"\n";
			description_b += temp;
		}
%>	
		<tr>
<%
	boolean isAdmin = UserUtil.isAdmin(Integer.parseInt("".endsWith(user_id)?"0":user_id));
	if(scheduleBean.getEdit() || isAdmin){
%>		
			<td align="center" nowrap="nowrap"><input type="checkbox" name="check" value="<%=scheduleBean.getJobName() %>" class="ainput"></td>
<%
	}else {
%>
			<td align="center" nowrap="nowrap"><input type="checkbox" name="check" disabled="disabled" value="<%=scheduleBean.getJobName() %>" class="ainput"></td>
<%
	}
%>
			<td nowrap="nowrap"><a href="#" onclick="showMonitor('<%=scheduleBean.getJobName() %>');"><%=scheduleBean.getJobName() %></a></td>
			<!-- <td nowrap="nowrap"><%=scheduleBean.getJobGroup() %></td> -->
			<td nowrap="nowrap"><%=scheduleBean.getRepName() %></td>
			<!-- <td nowrap="nowrap"><a href="#" onclick="dependencyManagerDlg('<%=scheduleBean.getFullname() %>');"><%=Messages.getString("Scheduler.Table.Column.Dependencies") %></a></td> -->
			<td nowrap="nowrap"><%=state %></td>
			<td><%=description_b %></td>
			<td><%=scheduleBean.getNextFireTime()==null?"":scheduleBean.getNextFireTime() %></td>
			<td><%=scheduleBean.getErrorNoticeUserName()==null?"":scheduleBean.getErrorNoticeUserName().replaceAll(",", "<br>") %></td>
		</tr>
<%
	}
%>		
	</table>
	</form>
	<div id="dlg" class="x-hidden">
		<form id="dataForm" name="dataForm" action="" method="post">
			<input type="reset" style="display: none;"><input type="submit" style="display: none;">
			<input type="hidden" name="id">
			<table border="0" align="center" height="30" width="98%">
				<tr height="30">
					<td width="100"><%=Messages.getString("Scheduler.Dialog.Title.Name") %></td>
					<td>
						<input type="text" id="jobname" name="jobname" style="width: 195px" value="" maxlength="50">
						<div id="jobname_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Name.Warn.Empty") %></font></div>
						<div id="jobname_error" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Name.Warn.Error") %></font></div>
						<div id="jobname_exist" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Name.Warn.Exist") %></font></div>
					</td>
				</tr>
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.Description") %></td>
					<td>
						<textarea name="description" id="description" style="width: 195px" cols="3" maxlength="120" onkeyup="countlen();"></textarea>
						<div id="description_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Description.Warn.Empty") %></font></div>
					</td>
				</tr>
				<tr height="30" style="display: none;">
					<td><%=Messages.getString("Scheduler.Dialog.Title.Version") %></td>
					<td>
						<select id="version" name="version" onchange="selVersion('', '', '', '');" style="width: 195px;">
							<option value="<%=KettleEngine.VERSION_4_3 %>">Kettle V4.3</option>
 							<!-- <option value="<%=KettleEngine.VERSION_2_3 %>">KingbaseDI V2.0</option> -->
						</select>
					</td>
				</tr>
				<tr height="30" >
					<td><%=Messages.getString("Scheduler.Dialog.Title.Repository") %></td>
					<td><span id="rep_span"></span></td>
				</tr>
				<tr height="30" style="display:none;" >
					<td><%=Messages.getString("Scheduler.Dialog.Title.File") %></td>
					<td>
						<input type="text" id="file" name="file" style="width: 195px;" readonly="readonly" onclick="selFile();">
						<input type="hidden" id="filepath" name="filepath" >
						<input type="hidden" id="filetype" name="filetype" >
						<div id="file_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.File.Warn.Empty") %></font></div>
						<div id="connect_error" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Password.Warn.ConnectErr") %></font></div>
						<div id="repempty_error" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.Password.Warn.EmptyErr") %></font></div>
					</td>
				</tr>			
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.ErrorNotice") %></td>
					<td>
						<input type="text" id="errorNoticeUserName" name="errorNoticeUserName" style="width: 195px;" readonly="readonly" onclick="selUser();">
						<input type="hidden" id="errorNoticeUserId" name="errorNoticeUserId" >
					</td>
				</tr>
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.ExecType") %></td>
					<td name="execTypeTd" id="execTypeTd">
						<select id="execType" name="execType" onchange="changeExecType(this.value, '', '');" style="width: 195px;">
							<option value="<%=KettleEngine.EXECTYPE_LOCAL %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.LocalExec") %></option>
							<option value="<%=KettleEngine.EXECTYPE_REMOTE %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.RemoteExec") %></option>
							<option value="<%=KettleEngine.EXECTYPE_CLUSTER %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.ClusterExec") %></option>
							<option value="<%=KettleEngine.EXECTYPE_HA %>"><%=Messages.getString("Scheduler.Dialog.Title.ExecType.HAExec") %></option>
						</select>
					</td>
				</tr>
				<tr height="30" name="remoteServerTr" id="remoteServerTr" style="display:none;">
					<td><%=Messages.getString("Scheduler.Dialog.Title.RemoteServer") %></td>
					<td name="remoteServerTd" id="remoteServerTd"></td>
				</tr>
				<tr height="30" name="haTr" id="haTr" style="display:none;">
					<td><%=Messages.getString("Scheduler.Dialog.Title.HACluster") %></td>
					<td>
						<select id="ha" name="ha" style="width: 195px;">
<%
						for(HAClusterBean haCluster : listHACluster){
%>
							<option value="<%=haCluster.getId_cluster() %>"><%=haCluster.getName() %></option>
<%
						}
%>
						</select>
					</td>
				</tr>
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.StartTime") %></td>
					<td>
						<input type="text" name="starttime" id="starttime" onclick="WdatePicker({dateFmt:'HH:mm:ss'});" readonly="readonly" style="width: 195px">
						<div id="starttime_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.StartTime.Warn.Empty") %></font></div>
						<div id="starttime_small" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.StartTime.Warn.Small") %></font></div>
					</td>
				</tr>
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.Cycle") %></td>
					<td>
						<select id="cycle" name="cycle" onchange="changeCycle();" style="width: 195px;">
							<option value="<%=ScheduleUtil.MODE_ONCE %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Once") %></option>
							<option value="<%=ScheduleUtil.MODE_SECOND %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Second") %></option>
							<option value="<%=ScheduleUtil.MODE_MINUTE %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Minute") %></option>
							<option value="<%=ScheduleUtil.MODE_HOUR %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Hour") %></option>
							<option value="<%=ScheduleUtil.MODE_DAY %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Day") %></option>
							<option value="<%=ScheduleUtil.MODE_WEEK %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Week") %></option>
							<option value="<%=ScheduleUtil.MODE_MONTH %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Month") %></option>
							<option value="<%=ScheduleUtil.MODE_YEAR %>"><%=Messages.getString("Scheduler.Dialog.Title.Cycle.Year") %></option>
						</select>
					</td>
				</tr>
				<tr id="cyclemode_td" height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.CycleMode") %></td>
					<td>
						<span id="cyclemode_span"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Every") %><input type="text" id="cyclenum" name="cyclenum" style="width: 30px;"><%=Messages.getString("Scheduler.Dialog.SchedulerPolicy.Second.Time") %></span>
						<div id="cyclenum_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.CycleMode.Warn.Empty") %></font></div>
						<div id="cyclenum_integer" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.CycleMode.Warn.Integer") %></font></div>
					</td>
				</tr>
				<tr height="30">
					<td><%=Messages.getString("Scheduler.Dialog.Title.StartDate") %></td>
					<td>
						<input type="text" name="startdate" id="startdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'});" readonly="readonly" style="width: 195px">
						<div id="startdate_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.StartDate.Warn.Empty") %></font></div>
						<div id="startdate_small" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.StartDate.Warn.Small") %></font></div>
					</td>
				</tr>
				<tr height="30" id="enddate_td">
					<td><%=Messages.getString("Scheduler.Dialog.Title.EndDate") %></td>
					<td>
						<input type="radio" id="enddateRadio" name="enddateRadio" checked="checked" value="0" onchange="enableEnddate(this.value);"><%=Messages.getString("Scheduler.Dialog.Title.EndDate.NeverEnd") %>
						<input type="radio" id="enddateRadio" name="enddateRadio" value="1" onchange="enableEnddate(this.value);"><input type="text" disabled="disabled" name="enddate" id="enddate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'});" style="width: 117px;">
						<input type="hidden" id="haveenddate" name="haveenddate" value="0">
						<div id="enddate_empty" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.EndDate.Warn.Empty") %></font></div>
						<div id="enddate_big" style="display:none;"><font color="red"><%=Messages.getString("Scheduler.Dialog.Title.EndDate.Warn.EndBigger") %></font></div>
					</td>
				</tr>
			</table>
		</form>
	</div>
	<div id="dlg_file" class="x-hidden"></div>
	<div id="dlg_dependencies" class="x-hidden">
	<br/>
	<div>
	<h1>已有依赖 &nbsp;&nbsp;&nbsp;&nbsp;<input type=button onclick="showAddDependency();" value="新增"/></h1>
	<table id="jobdependencies" width=100%></table>	
	</div>
	
	<!-- <input type="hidden" id="jobname" name="jobname" value=""/>-->
	<input type="hidden" id="jobgroup" name="jobgroup" value="<%=userBeanSession.getOrgId() %>"/>
	<br/>
	<div id="divNewDependency" style="display:none">
		<select id="jobfullname" name="jobfullname" WIDTH="200" STYLE="width: 200px" >
			<!-- <option>选择调度</option>
			<optgroup label="DEFAULT"><option>2222</option></optgroup><optgroup label="DS"><option>3333</option><option>44444</option></optgroup>
			-->
		</select>
		<select id="djobfullname" name="djobfullname" WIDTH="200" STYLE="width: 200px" >
			<!-- <option>选择依赖调度</option>
			<optgroup label="DEFAULT"><option>1111</option></optgroup><optgroup label="DS"><option>2222</option><option>3333</option></optgroup>
			 -->
		</select>
		<input type="button" onclick="addDependency();" value="确定"/>
	</div>
		
	</div>
	<div id="dlg_users" class="x-hidden">
		<select id="selUsers" name="selUsers" multiple="multiple" style="width: 195px" size="15">
<%
		for(UserBean userBean : listUsers){
%>		
			<option value="<%=userBean.getUser_id() %>"><%=userBean.getEmail() + "(" + userBean.getNick_name() + ")" %></option>
<%
		}
%>
		</select>
	</div>
</body>
</html>
