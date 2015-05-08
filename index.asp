<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>FindIt 2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<link rel="stylesheet" href="css/custom.css" />
	<script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript" src="js/app.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		var SearchText;
		
		$(document).ready(function() {
			var FindItObj = new FindIt(RqlConnectorObj);

		});

	</script>
	
	<script id="template-search-option-dialog" type="text/x-handlebars-template" data-container="#search-option-dialog" data-action="replace">
		<div class="modal fade" data-backdrop="static" role="dialog">
			<div class="modal-header">
				<h3>FindIt 2 - a template code search tool</h3>
			</div>
			<div class="modal-body">
				<div class="form-horizontal">
					<div class="control-group">
						<label class="control-label">Find what</label>
						<div class="controls">
							<input class="input-block-level" type="text" />
							<label class="checkbox" ><input type="checkbox" /> Case sensitive</label>
						</div>
					</div>
					<div class="control-group">
						<label class="control-label">In Content Class Folder</label>
						<div class="controls content-class-folders">
							<div class="alert">Loading...</div>
						</div>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<div class="btn btn-success find">Find</div>
			</div>
		</div>
	</script>
	
	<script id="template-code-dialog" type="text/x-handlebars-template" data-container="#code" data-action="replace">
		<div class="modal fade" role="dialog">
			<div class="modal-header">
				<h3>Code</h3>
			</div>
			<div class="modal-body">
				<div class="alert">Loading</div>
			</div>
		</div>
	</script>
	
	<script id="template-code-dialog-header" type="text/x-handlebars-template" data-container="#code .modal-header" data-action="replace">
		<h3>{{name}}</h3>
	</script>
	
	<script id="template-code-dialog-body" type="text/x-handlebars-template" data-container="#code .modal-body" data-action="replace">
		<pre>
			{{code}}
		</pre>
	</script>
	
	<script id="template-search-option-content-class-folders" type="text/x-handlebars-template" data-container="#search-option-dialog .content-class-folders" data-action="replace">
		<select class="input-block-level">
			{{#each contentclassfolders}}
			<option value="{{guid}}">{{name}}</option>
			{{/each}}
		</select>
	</script>
	
	<script id="template-status-processing" type="text/x-handlebars-template" data-container="#status" data-action="replace">
		<div class="alert">
			<h4>Searching {{name}}</h4>
			{{currentcount}}/{{totalcount}} content classes.
		</div>
	</script>
	
	<script id="template-status-completed" type="text/x-handlebars-template" data-container="#status" data-action="replace">
		<div class="alert alert-success">
			<h4>Search completed</h4>
			Search term "{{searchtext}}" found in {{contentclassesfound}} content classes.
		</div>
	</script>
	
	<script id="template-result" type="text/x-handlebars-template" data-container="#results" data-action="append">
		<div class="alert alert-info">
			<div class="btn open-template" data-guid="{{guid}}"><span title="Open Template" alt="Open Template" class="icon-eye-open"></span></div>
			<div class="btn btn-link content-class-in-tree" data-guid="{{guid}}" data-treetype="app.4015" title="Display Content Class in Tree" alt="Display Content Class in Tree">{{name}}</div>
		</div>
	</script>
</head>
<body>
	<div id="search-option-dialog">
	</div>
	<div id="code">
	</div>
    <div id="status">
    </div>
	<div id="results">
	</div>
</body>
</html>