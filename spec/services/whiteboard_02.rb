{: site => "https://tallerflow.atlassian.net/",: context_path => "/",: rest_base_path => "//rest/api/2",: ssl_verify_mode => 1,: use_ssl => true,: use_client_cert => false,: auth_type =>: basic,: http_debug => false,: username => "celso@taller.net.br",: password => "roots1981",: read_timeout => 120
}, @request_client = # < JIRA::HttpClient: 0x00007ff8d0161680 @options = {: username => "celso@taller.net.br",
  : password => "roots1981",
  : site => "https://tallerflow.atlassian.net/",
  : context_path => "/",
  : rest_base_path => "//rest/api/2",
  : ssl_verify_mode => 1,
  : use_ssl => true,
  : use_client_cert => false,
  : auth_type =>: basic,
  : http_debug => false,
  : read_timeout => 120
}, @cookies = {}, @authenticated = true > , @http_debug = false, @cache = # < OpenStruct >> , @attrs = {
  "id" => "10954",
  "expand" => "renderedFields,names,schema,operations,editmeta,changelog,versionedRepresentations",
  "self" => "https://tallerflow.atlassian.net/rest/api/2/issue/10954",
  "key" => "FC-247",
  "changelog" => {
    "startAt" => 0, "maxResults" => 1, "total" => 1, "histories" => [{
      "id" => "17311",
      "author" => {
        "self" => "https://tallerflow.atlassian.net/rest/api/2/user?accountId=557058%3A65bf1bee-3dcb-46a3-8afd-664590346c4e", "name" => "celso", "key" => "celso", "accountId" => "557058:65bf1bee-3dcb-46a3-8afd-664590346c4e", "emailAddress" => "celso@taller.net.br", "avatarUrls" => {
          "48x48" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue", "24x24" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue", "16x16" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue", "32x32" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"
        }, "displayName" => "Celso Martins", "active" => true, "timeZone" => "America/Sao_Paulo"
      },
      "created" => "2019-03-25T20:11:50.573-0300",
      "items" => [{
        "field" => "Flagged",
        "fieldtype" => "custom",
        "fieldId" => "customfield_10023",
        "from" => nil,
        "fromString" => nil,
        "to" => "[10019]",
        "toString" => "Impediment"
      }]
    }]
  },
  "fields" => {
    "issuetype" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/issuetype/10001", "id" => "10001", "description" => "Stories track functionality or features expressed as user goals.", "iconUrl" => "https://tallerflow.atlassian.net/secure/viewavatar?size=xsmall&avatarId=10315&avatarType=issuetype", "name" => "Story", "subtask" => false, "avatarId" => 10315
    }, "timespent" => nil, "customfield_10030" => nil, "customfield_10031" => nil, "project" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/project/10000", "id" => "10000", "key" => "FC", "name" => "Flow Climate", "projectTypeKey" => "software", "avatarUrls" => {
        "48x48" => "https://tallerflow.atlassian.net/secure/projectavatar?avatarId=10324", "24x24" => "https://tallerflow.atlassian.net/secure/projectavatar?size=small&avatarId=10324", "16x16" => "https://tallerflow.atlassian.net/secure/projectavatar?size=xsmall&avatarId=10324", "32x32" => "https://tallerflow.atlassian.net/secure/projectavatar?size=medium&avatarId=10324"
      }
    }, "customfield_10032" => nil, "customfield_10033" => [], "fixVersions" => [{
      "self" => "https://tallerflow.atlassian.net/rest/api/2/version/10018",
      "id" => "10018",
      "description" => "Issues to deal with the findings of the world",
      "name" => "Get Out Of The Building",
      "archived" => false,
      "released" => false,
      "releaseDate" => "2019-04-30"
    }], "aggregatetimespent" => nil, "customfield_10036" => nil, "customfield_10037" => nil, "customfield_10027" => nil, "customfield_10028" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/customFieldOption/10020", "value" => "Default", "id" => "10020"
    }, "customfield_10029" => nil, "resolutiondate" => nil, "workratio" => -1, "lastViewed" => "2019-03-25T20:11:42.052-0300", "watches" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/issue/FC-247/watchers", "watchCount" => 1, "isWatching" => true
    }, "created" => "2019-03-25T20:10:35.341-0300", "customfield_10023" => [{
      "self" => "https://tallerflow.atlassian.net/rest/api/2/customFieldOption/10019",
      "value" => "Impediment",
      "id" => "10019"
    }], "customfield_10024" => nil, "labels" => [], "customfield_10016" => nil, "customfield_10017" => "1|i000an:", "aggregatetimeoriginalestimate" => nil, "timeestimate" => nil, "issuelinks" => [], "updated" => "2019-03-25T20:11:50.672-0300", "status" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/status/10000", "description" => "", "iconUrl" => "https://tallerflow.atlassian.net/", "name" => "Backlog", "id" => "10000", "statusCategory" => {
        "self" => "https://tallerflow.atlassian.net/rest/api/2/statuscategory/2", "id" => 2, "key" => "new", "colorName" => "blue-gray", "name" => "To Do"
      }
    }, "timeoriginalestimate" => nil, "description" => nil, "customfield_10013" => nil, "customfield_10014" => nil, "customfield_10015" => {
      "hasEpicLinkFieldDependency" => false, "showField" => false, "nonEditableReason" => {
        "reason" => "PLUGIN_LICENSE_ERROR", "message" => "Portfolio for Jira must be licensed for the Parent Link to be available."
      }
    }, "aggregatetimeestimate" => nil, "attachment" => [], "summary" => "Card test block", "creator" => {
      "self" => "https://tallerflow.atlassian.net/rest/api/2/user?accountId=557058%3A65bf1bee-3dcb-46a3-8afd-664590346c4e", "name" => "celso", "key" => "celso", "accountId" => "557058:65bf1bee-3dcb-46a3-8afd-664590346c4e", "emailAddress" => "celso@taller.net.br", "avatarUrls" => {
        "48x48" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue", "24x24" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue", "16x16" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue", "32x32" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"
      }, "displayName" => "Celso Martins", "active" => true, "timeZone" => "America/Sao_Paulo"
    }, "subtasks" => [], "customfield_10041" => nil, "aggregateprogress" => {
      "progress" => 0, "total" => 0
    }, "customfield_10000" => "{}", "customfield_10001" => nil, "customfield_10045" => nil, "customfield_10002" => nil, "customfield_10047" => nil, "customfield_10038" => nil, "environment" => nil, "duedate" => nil, "progress" => {
      "progress" => 0, "total" => 0
    }, "comment" => {
      "comments" => [{
        "self" => "https://tallerflow.atlassian.net/rest/api/2/issue/10954/comment/10956",
        "id" => "10956",
        "author" => {
          "self" => "https://tallerflow.atlassian.net/rest/api/2/user?accountId=557058%3A65bf1bee-3dcb-46a3-8afd-664590346c4e", "name" => "celso", "key" => "celso", "accountId" => "557058:65bf1bee-3dcb-46a3-8afd-664590346c4e", "emailAddress" => "celso@taller.net.br", "avatarUrls" => {
            "48x48" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue", "24x24" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue", "16x16" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue", "32x32" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"
          }, "displayName" => "Celso Martins", "active" => true, "timeZone" => "America/Sao_Paulo"
        },
        "body" => "(flag) Flag added\n\ntestando motivo na API",
        "updateAuthor" => {
          "self" => "https://tallerflow.atlassian.net/rest/api/2/user?accountId=557058%3A65bf1bee-3dcb-46a3-8afd-664590346c4e", "name" => "celso", "key" => "celso", "accountId" => "557058:65bf1bee-3dcb-46a3-8afd-664590346c4e", "emailAddress" => "celso@taller.net.br", "avatarUrls" => {
            "48x48" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue", "24x24" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue", "16x16" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue", "32x32" => "https://avatar-cdn.atlassian.com/509751c4de4b5433c831fbc1e529eb0e?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F509751c4de4b5433c831fbc1e529eb0e%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"
          }, "displayName" => "Celso Martins", "active" => true, "timeZone" => "America/Sao_Paulo"
        },
        "created" => "2019-03-25T20:11:50.672-0300",
        "updated" => "2019-03-25T20:11:50.672-0300",
        "jsdPublic" => true
      }], "maxResults" => 1, "total" => 1, "startAt" => 0
    }
  }
}, @expanded = true, @deleted = false >
