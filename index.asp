<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>FindIt 2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type="text/css">
		body
		{
			padding: 10px;
		}
		#search-result-template
		{
			display: none;
		}
		input
		{
			width: 95%;
		}
	</style>
	<script type="text/javascript">
		function GotoTreeSegment(sGuid, sType)
		{
			top.opener.parent.parent.parent.ioTreeIFrame.frames.ioTreeFrames.frames.ioTree.ShowInfoLabel();
			top.opener.parent.frames.ioTreeData.location='../../ioRDLevel1.asp?Action=GotoTreeSegment&Guid=' + sGuid + '&Type=' + sType + '&CalledFromRedDot=0';
		}
	</script>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		var SearchText;
		
		$(document).ready(function() {
			ListContentClassFolders();
			
			$('#search-option-dialog').modal('show');
		});
		
		function Find()
		{
			SearchText = $('#search-field').val();
			SearchText = $.trim(SearchText);
			
			if(SearchText == '')
			{
				alert('Field under "Find what" cannot be empty.');
				return;
			}
			
			$('#search-option-dialog').modal('hide');

			// all or specific content class
			var strRQLXML;
			var FolderGuid = $('#content-class-folders option:selected').val();
			if(FolderGuid == '')
			{
				strRQLXML = '<TEMPLATES folderguid="" action="list"/>';
			}
			else
			{
				strRQLXML = '<TEMPLATELIST action="load" folderguid="' + FolderGuid + '"/>';
			}
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				var TempItems = new Array();
			
				$(data).find('TEMPLATE').each(function(){
					var ContentClassObj = new Object();
					ContentClassObj.guid = $(this).attr('guid');
					ContentClassObj.name = $(this).attr('name');
					
					TempItems.push(ContentClassObj);
				});
				
				$('#searchresults').show();
				
				Findtemplate(TempItems);
			});
		}
		
		function isCaseSensitive()
		{
			return $('#check-box-case-sensitive').is(':checked');
		}
		
		function Findtemplate(InputArray)
		{
			var ToBeProcessItem = InputArray.shift();

			if(ToBeProcessItem != null)
			{
				// parse and get guid
				ToBeProcessItemGuid = ToBeProcessItem.guid;
				ToBeProcessItemHeadline = ToBeProcessItem.name;
				
				// change status text
				$('#status').html('<div>' + InputArray.length + ' remaining</div><div>Searching in ' + ToBeProcessItemHeadline + '</div>');
				
				var strRQLXML = '<PROJECT><TEMPLATE action="load" guid="' + ToBeProcessItemGuid + '"><TEMPLATEVARIANTS readonly="1" action="loadfirst"/></TEMPLATE></PROJECT>';

				RqlConnectorObj.SendRql(strRQLXML, false, function(data){
					var TemplateText = $(data).find('TEMPLATEVARIANT').text();
					
					// search for placeholders
					var TemplateRegexp;
					
					if(isCaseSensitive())
					{
						TemplateRegexp = new RegExp(SearchText, '');
					}
					else
					{
						TemplateRegexp = new RegExp(SearchText, 'i');
					}

					if(TemplateText.search(TemplateRegexp) > -1)
					{
						var ResultHTML = '<div class="alert alert-info">';
						ResultHTML += '<a href="#" onclick="Popup(\'' + $(data).find('TEMPLATEVARIANT').attr('guid') + '\')" title="Open Template" alt="Open Template" class="icon-eye-open"></a>&nbsp;';
						ResultHTML += '<a title="Display Content Class in Tree" alt="Display Content Class in Tree" href="javascript:GotoTreeSegment(\'' + ToBeProcessItemGuid + '\', \'app.4015\');">' + ToBeProcessItemHeadline + '</a>';
						ResultHTML += '</div>';
						$('#results').append(ResultHTML);
					}
					
					Findtemplate(InputArray);
				});
			}
			else
			{
				$('#status').html('<div>Search completed</div><div>' + $('#results .alert').length + ' found</div>');
				$('#status').addClass('alert-success');
			}
		}
		
		function ListContentClassFolders()
		{
			var strRQLXML = '<PROJECT><FOLDERS action="list" foldertype="1"/></PROJECT>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				$(data).find('FOLDER').each(function(){
					$('#content-class-folders').append('<option value="' + $(this).attr('guid') + '">' + $(this).attr('name') + '</option>');
				});
			});
		}
		
		function Popup(TemplateGuid)
		{
			var PopUpUrl = '/CMS/ioTemplateEditor/ioTemplateEditor.asp?ReadOnly=1&FlatStyle=1&TemplateVariantGuid=' + TemplateGuid;
			window.open(PopUpUrl, 'CodeViewer', 'width=800,height=600,scrollbars=no,resizable=yes'); 
		}
	</script>
</head>
<body>
	<div id="search-option-dialog" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">FindIt 2 - a template code search tool</h3>
		</div>
		<div class="modal-body">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label" for="search-field">Find what</label>
					<div class="controls">
						<input type="text" id="search-field"/>
						<label class="checkbox" for="check-box-case-sensitive"><input type="checkbox" id="check-box-case-sensitive"/> Case sensitive</label>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label" for="content-class-folders">In Content Class Folder</label>
					<div class="controls">
						<select id="content-class-folders">
							<option selected="selected" value="">All Content Class Folders</option>
						</select>
					</div>
				</div>
			</div>
		</div>
		<div class="modal-footer">
			<a href="#" class="btn btn-success" onclick="Find()">Find</a>
		</div>
	</div>
    <div class="alert" id="status">
    </div>
	<div id="results">
	</div>
</body>
</html>