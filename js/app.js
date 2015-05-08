function FindIt(RqlConnectorObj) {
	this.RqlConnectorObj = RqlConnectorObj;
	
	this.TemplateSearchOptionDialog = '#template-search-option-dialog';
	this.TemplateCodeDialog = '#template-code-dialog';
	this.TemplateCodeDialogHeader = '#template-code-dialog-header';
	this.TemplateCodeDialogBody = '#template-code-dialog-body';
	this.TemplateSearchOptionContentClassFolders = '#template-search-option-content-class-folders';
	this.TemplateStatusProcessing = '#template-status-processing';
	this.TemplateStatusCompleted = '#template-status-completed';
	this.TemplateResult = '#template-result';

	this.Init();
}

FindIt.prototype.Init = function() {
	var ThisClass = this;
	
	var ResultContainer = $(this.TemplateResult).attr('data-container');
	$(ResultContainer).on('click', '.content-class-in-tree', function(){
		var ContentClassGuid = $(this).attr('data-guid');
		var ContentClassTreeType = $(this).attr('data-treetype');
		
		ThisClass.GotoTreeSegment(ContentClassGuid, ContentClassTreeType);
	});
	
	$(ResultContainer).on('click', '.open-template', function(){
		var ContentClassGuid = $(this).attr('data-guid');
	
		ThisClass.UpdateArea(ThisClass.TemplateCodeDialog, undefined);
		
		var CodeDialogContainer = $(ThisClass.TemplateCodeDialog).attr('data-container');
		$(CodeDialogContainer).find('.modal').modal('show');
		
		ThisClass.LoadTemplate(ContentClassGuid);
	});
	
	var SearchOptionDialogContainer = $(this.TemplateSearchOptionDialog).attr('data-container');
	$(SearchOptionDialogContainer).on('click', '.find', function(){
		var ContentClassFolderGuid = $(SearchOptionDialogContainer).find('option:selected').val();
		var SearchText = $(SearchOptionDialogContainer).find('input[type="text"]').val();
		SearchText = $.trim(SearchText);
		var IsCaseSensitive = $(SearchOptionDialogContainer).find('input:checked').length > 0 ? true : false;

		if(SearchText){
			ThisClass.Find(ContentClassFolderGuid, SearchText, IsCaseSensitive);
			
			$(SearchOptionDialogContainer).find('.modal').modal('hide');
		}
	});

	this.UpdateArea(this.TemplateSearchOptionDialog, undefined);
	$(SearchOptionDialogContainer).find('.modal').modal('show');
	this.ListContentClassFolders();
}

FindIt.prototype.Find = function(ContentClassFolderGuid, SearchText, IsCaseSensitive) {
	var ThisClass = this;
	var RqlXml;

	if(ContentClassFolderGuid){
		RqlXml = '<TEMPLATELIST action="load" folderguid="' + ContentClassFolderGuid + '"/>';
	} else {
		RqlXml = '<TEMPLATES folderguid="" action="list"/>';
	}
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var TemplatesDom = $(data).find('TEMPLATE');
		var TotalCount = TemplatesDom.length;
		var ContentClasses = [];
	
		
		TemplatesDom.each(function(index){
			var ContentClass = {
				'name': $(this).attr('name'),
				'guid': $(this).attr('guid'),
				'currentcount': index,
				'totalcount': TotalCount
			};
			
			ContentClasses.push(ContentClass);
		});
		
		ThisClass.FindInTemplate(ContentClasses, SearchText, IsCaseSensitive, 0);
	});
}

FindIt.prototype.FindInTemplate = function(ContentClasses, SearchText, IsCaseSensitive, ContentClassesFound) {
	var ThisClass = this;
	
	if(!ContentClassesFound){
		ContentClassesFound = 0;
	}
	
	var ContentClass = ContentClasses.shift();

	if(ContentClass != null)
	{
		this.UpdateArea(this.TemplateStatusProcessing, ContentClass);
	
		var RqlXml = '<PROJECT><TEMPLATE action="load" guid="' + ContentClass.guid + '"><TEMPLATEVARIANTS readonly="1" action="loadfirst"/></TEMPLATE></PROJECT>';

		RqlConnectorObj.SendRql(RqlXml, false, function(data){
			var TemplateText = $(data).find('TEMPLATEVARIANT').text();
			
			// search for placeholders
			var TemplateRegexp;
			
			if(IsCaseSensitive)
			{
				TemplateRegexp = new RegExp(SearchText, '');
			}
			else
			{
				TemplateRegexp = new RegExp(SearchText, 'i');
			}

			if(TemplateText.search(TemplateRegexp) > -1)
			{
				ContentClassesFound += 1;
				ThisClass.UpdateArea(ThisClass.TemplateResult, ContentClass);
			}
			
			ThisClass.FindInTemplate(ContentClasses, SearchText, IsCaseSensitive, ContentClassesFound);
		});
	} else {
		this.UpdateArea(this.TemplateStatusCompleted, {'contentclassesfound': ContentClassesFound, 'searchtext': SearchText});
	}
}

FindIt.prototype.LoadTemplate = function(ContentClassGuid) {
	var ThisClass = this;

	var RqlXml = '<PROJECT><TEMPLATE action="load" guid="' + ContentClassGuid + '"><TEMPLATEVARIANTS readonly="1" action="loadfirst"/></TEMPLATE></PROJECT>';

	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var ContentClass = {
			'name': $(data).find('TEMPLATE').attr('name'),
			'code': $(data).find('TEMPLATEVARIANT').text()
		}
	
		ThisClass.UpdateArea(ThisClass.TemplateCodeDialogHeader, ContentClass);
		ThisClass.UpdateArea(ThisClass.TemplateCodeDialogBody, ContentClass);
	});
}

FindIt.prototype.ListContentClassFolders = function() {
	var ThisClass = this;
	var RqlXml = '<PROJECT><FOLDERS action="list" foldertype="1"/></PROJECT>';
	var ContentClassFolders = [];
	
	RqlConnectorObj.SendRql(RqlXml, false, function(data){
		ContentClassFolders.push({
			'name': 'All',
			'guid': ''
		});

		$(data).find('FOLDER').each(function(){
			var ContentClassFolder = {
				'name': $(this).attr('name'),
				'guid': $(this).attr('guid')
			};

			ContentClassFolders.push(ContentClassFolder);
		});
		
		ThisClass.UpdateArea(ThisClass.TemplateSearchOptionContentClassFolders, {'contentclassfolders': ContentClassFolders});
	});
}

FindIt.prototype.GotoTreeSegment = function(Guid, Type){
	if(top.opener.parent.frames.ioTreeData){
		// MS 10 or less
		top.opener.parent.frames.ioTreeData.document.location = '../../ioRDLevel1.asp?Action=GotoTreeSegment&Guid=' + Guid + '&Type=' + Type + '&CalledFromRedDot=0';
	} else {
		// MS 11
		top.opener.parent.parent.parent.ioTreeIFrame.frames.ioTreeFrames.frames.ioTree.GotoTreeSegment(Guid, Type);
	}
}

FindIt.prototype.UpdateArea = function(TemplateId, Data){
	var ContainerId = $(TemplateId).attr('data-container');
	var TemplateAction = $(TemplateId).attr('data-action');
	var Template = Handlebars.compile($(TemplateId).html());
	var TemplateData = Template(Data);

	if((TemplateAction == 'append') || (TemplateAction == 'replace'))
	{
		if (TemplateAction == 'replace') {
			$(ContainerId).empty();
		}

		$(ContainerId).append(TemplateData);
	}

	if(TemplateAction == 'prepend')
	{
		$(ContainerId).prepend(TemplateData);
	}

	if(TemplateAction == 'after')
	{
		$(ContainerId).after(TemplateData);
	}
}