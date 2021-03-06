<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.archive.wayback.ResultURIConverter" %>
<%@ page import="org.archive.wayback.WaybackConstants" %>
<%@ page import="org.archive.wayback.core.CaptureSearchResult" %>
<%@ page import="org.archive.wayback.core.CaptureSearchResults" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.core.WaybackRequest" %>
<%@ page import="org.archive.wayback.partition.BubbleCalendarData" %>
<%@ page import="org.archive.wayback.util.partition.Partition" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>

<%
  UIResults results = UIResults.extractCaptureQuery(request);

  StringFormatter fmt = results.getWbRequest().getFormatter();
  ResultURIConverter uriConverter = results.getURIConverter();

  // deployment-specific URL prefixes
  String staticPrefix = results.getStaticPrefix();
  String queryPrefix = results.getQueryPrefix();
  String replayPrefix = results.getReplayPrefix();

  //deployment-specific address for the graph generator:
  String graphJspPrefix = results.getContextConfig("graphJspPrefix");
  if (graphJspPrefix == null) {
    graphJspPrefix = queryPrefix;
  }

  // graph size "constants": These are currently baked-in to the JS logic...
  int imgWidth = 0;
  int imgHeight = 75;
  int yearWidth = 49;
  int monthWidth = 5;

  for (int year = 1991; year <= Calendar.getInstance().get(Calendar.YEAR); year++)
    imgWidth += yearWidth;

  BubbleCalendarData data = new BubbleCalendarData(results);

  String yearEncoded = data.getYearsGraphString(imgWidth,imgHeight);
  String yearImgUrl = graphJspPrefix + "jsp/graph.jsp?graphdata=" + yearEncoded;

  // a Calendar object for doing days-in-week, day-of-week,days-in-month math:
  Calendar cal = BubbleCalendarData.getUTCCalendar();
%>

<jsp:include page="/WEB-INF/template/UI-header.jsp" flush="true" />

<!-- Main page content -->
<div id="main-container" class="calendar-results">
  <div class="container">
    <div class="row">
      <div id="content" class="col-sm-12">
        <h2>
           Captured
           <span class="result-count">
             <%= fmt.format("{0} times",data.numResults) %>
           </span>
           between
           <span class="search-date">
             <a href="<%= data.firstResultReplayUrl %>"><%= fmt.format("{0,date,MMMM d, yyyy}",data.firstResultDate) %></a>
          </span>
          and
          <span class="search-date">
            <a href="<%= data.lastResultReplayUrl %>"><%= fmt.format("{0,date,MMMM d, yyyy}",data.lastResultDate) %></a>
         </span>
        </h2>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-sm-12">
      <div id="wbChart" onmouseout="showTrackers('none'); setActiveYear(startYear);">
        <div id="wbChartThis">
          <a style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;" href="<%= queryPrefix %>" id="wm-graph-anchor">
            <div id="wm-ipp-sparkline" style="position:relative; white-space:nowrap; width:<%= imgWidth %>px;height:<%= imgHeight %>px;cursor:pointer;" title="<%= fmt.format("ToolBar.sparklineTitle") %>">
              <img id="sparklineImgId" style="position:absolute;z-index:9012;top:0;left:0;"
                onmouseover="showTrackers('inline');"
                onmousemove="trackMouseMove(event,this)"
                alt="sparklines"
                width="<%= imgWidth %>"
                height="<%= imgHeight %>"
                border="0"
                src="<%= yearImgUrl %>"></img>
              <img id="wbMouseTrackYearImg"
                style="display:none; position:absolute; z-index:9010;"
                width="<%= yearWidth %>"
                height="<%= imgHeight %>"
                border="0"
                src="<%= staticPrefix %>images/toolbar/transp-white-pixel.png"></img>
              <img id="wbMouseTrackMonthImg"
                style="display:none; position:absolute; z-index:9011; "
                width="<%= monthWidth %>"
                height="<%= imgHeight %>"
                border="0"
                src="<%= staticPrefix %>images/toolbar/transp-yellow-pixel.png"></img>
            </div>
          </a>
          <%
            for (int i = 1991; i <= Calendar.getInstance().get(Calendar.YEAR); i++) {
              String curClass = "inactiveHighlight";
              String locationClass = "middle";
              if (data.yearNum == i) {
                curClass = "activeHighlight";
              }
              if (i == 1991) {
                locationClass = "leftmost";
              }
              if (i == Calendar.getInstance().get(Calendar.YEAR)) {
                locationClass = "rightmost";
              }
          %>
          <div class="wbChartThisContainer <%= locationClass %>">
            <a style="text-decoration: none;" href="<%= queryPrefix + i + "0201000000*/" + data.searchUrlForHTML %>">
              <div id="highlight-<%= i - 1991 %>"
                onmouseover="showTrackers('inline'); setActiveYear(<%= i - 1991 %>)"
                class="<%= curClass %>"><%= i %></div>
            </a>
          </div>
          <%
            }
          %>
        </div>
      </div>
    </div>
  </div>

  <div class="container">
    <div class="row">
      <div class="col-sm-12">
        <div id="wbCalendar">
          <div id="calUnder" class="calPosition">
            <%
              // draw 12 months, 0-11 (0=Jan, 11=Dec)
              for (int moy = 0; moy < 12; moy++) {
                Partition<Partition<CaptureSearchResult>> curMonth = data.monthsByDay.get(moy);
                List<Partition<CaptureSearchResult>> monthDays = curMonth.list();
            %>
            <div class="month" id="<%= data.yearNum %>-<%= moy %>">
              <table>
                <thead>
                  <tr>
                    <th colspan="7"><span class="label"></span></th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <%
                      cal.setTime(curMonth.getStart());
                      int skipDays = cal.get(Calendar.DAY_OF_WEEK) - 1;
                      int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
                      // skip until the 1st:
                      for (int i = 0; i < skipDays; i++) {
                    %>
                    <td>
                      <div class="date"></div>
                    </td>
                    <%
                      }
                      int dow = skipDays;
                      int dom;
                      for (dom = 0; dom < daysInMonth; dom++) {
                        int count = monthDays.get(dom).count();
                        if (count > 0) {
                          // one or more captures in this day:
                          CaptureSearchResult firstCaptureInDay = monthDays.get(dom).list().get(0);
                          String replayUrl = uriConverter.makeReplayURI(
                            firstCaptureInDay.getCaptureTimestamp(),
                            firstCaptureInDay.getOriginalUrl());
                          Date firstCaptureInDayDate = firstCaptureInDay.getCaptureDate();
                          String safeUrl = fmt.escapeHtml(replayUrl);
                    %>
                    <td>
                      <div class="date">
                        <div class="position">
                          <div class="hidden"><%= count %></div>
                          <div class="measure opacity20" id="<%= fmt.format("{0,date,MMM-d-yyyy}",firstCaptureInDayDate) %>">
                            <img width="100%" height="100%"/>
                          </div>
                        </div>
                      </div>
                    </td>
                    <%
                      } else {
                        // zero captures in this day:
                    %>
                    <td>
                      <div class="date"></div>
                    </td>
                    <%
                      }
                      if (((dom+skipDays+1) % 7) == 0) {
                        // end of the week, start a new tr:
                    %>
                  </tr>
                  <tr>
                    <%
                        }
                      }
                      // fill in blank days until the end of the current week:
                      while(((dom+skipDays) % 7) != 0) {
                    %>
                    <td></td>
                    <%
                      dom++;
                      }
                    %>
                  </tr>
                </tbody>
              </table>
            </div>
            <%
              }
            %>
          </div>

          <div id="calOver" class="calPosition">
            <%
              for (int moy = 0; moy < 12; moy++) {
                Partition<Partition<CaptureSearchResult>> curMonth = data.monthsByDay.get(moy);
                List<Partition<CaptureSearchResult>> monthDays = curMonth.list();
            %>
            <div class="month" id="<%= data.yearNum %>-<%= moy %>">
              <table>
                <thead>
                  <tr>
                    <th colspan="7">
                      <span class="label"><%= fmt.format("{0,date,MMM}",curMonth.getStart()) %></span>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <%
                      cal.setTime(curMonth.getStart());
                      int skipDays = cal.get(Calendar.DAY_OF_WEEK) - 1;
                      int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
                      // skip until the 1st:
                      for (int i = 0; i < skipDays; i++) {
                    %>
                    <td>
                      <div class="date"></div>
                    </td>
                    <%
                      }
                      int dow = skipDays;
                      int dom;
                      for (dom = 0; dom < daysInMonth; dom++) {
                        int count = monthDays.get(dom).count();
                        if (count > 0) {
                          // one or more captures in this day:
                          CaptureSearchResult firstCaptureInDay = monthDays.get(dom).list().get(0);
                          String replayUrl = uriConverter.makeReplayURI(
                            firstCaptureInDay.getCaptureTimestamp(),
                            firstCaptureInDay.getOriginalUrl());
                          Date firstCaptureInDayDate = firstCaptureInDay.getCaptureDate();
                          String safeUrl = fmt.escapeHtml(replayUrl);
                    %>
                    <td>
                      <div class="date tooltip">
                        <div class="pop">
                          <h3><%= fmt.format("{0,date,MMMMM d, yyyy}",firstCaptureInDayDate) %></h3>
                          <p><%= count %> snapshots</p>
                          <ul>
                            <%
                              Iterator<CaptureSearchResult> dayItr = monthDays.get(dom).iterator();
                              while(dayItr.hasNext()) {
                                CaptureSearchResult c = dayItr.next();
                                String replayUrl2 = uriConverter.makeReplayURI(c.getCaptureTimestamp(),c.getOriginalUrl());
                                String safeUrl2 = fmt.escapeHtml(replayUrl2);
                            %>
                            <li>
                              <a href="<%= safeUrl2 %>"><%= fmt.format("{0,date,HH:mm:ss}",c.getCaptureDate()) %></a>
                            </li>
                            <%
                              }
                            %>
                          </ul>
                        </div>
                        <div class="day">
                          <a href="<%= safeUrl %>" title="<%= count %> snapshots"
                            class="<%= fmt.format("{0,date,MMM-d-yyyy}",firstCaptureInDayDate) %>"><%= dom + 1 %>
                          </a>
                        </div>
                      </div>
                    </td>
                    <%
                      } else {
                        // zero captures in this day:
                    %>
                    <td>
                      <div class="date">
                        <div class="day">
                          <span><%= dom + 1 %></span>
                        </div>
                      </div>
                    </td>
                    <%
                      }
                      if (((dom+skipDays+1) % 7) == 0) {
                        // end of the week, start a new tr:
                    %>
                  </tr>
                  <tr>
                    <%
                        }
                      }
                      // fill in blank days until the end of the current week:
                      while(((dom+skipDays) % 7) != 0) {
                    %>
                    <td></td>
                    <%
                        dom++;
                      }
                    %>
                  </tr>
                </tbody>
              </table>
            </div>
            <%
              }
            %>
          </div> <!-- end #calOver -->
        </div> <!-- end #wbCalendar -->

        <script type="text/javascript" src="<%= staticPrefix %>js/jquery-1.4.2.min.js"></script>
        <script type="text/javascript" src="<%= staticPrefix %>js/excanvas.compiled.js"></script>
        <script type="text/javascript" src="<%= staticPrefix %>js/jquery.bt.min.js" charset="utf-8"></script>
        <script type="text/javascript" src="<%= staticPrefix %>js/jquery.hoverintent.min.js" charset="utf-8"></script>
        <script type="text/javascript" src="<%= staticPrefix %>js/graph-calc.js" ></script>
        <!-- More ugly JS to manage the highlight over the graph -->
        <script type="text/javascript">
          var firstDate = <%= data.dataStartMSSE %>;
          var lastDate = <%= data.dataEndMSSE %>;
          var wbPrefix = "<%= replayPrefix %>";
          var wbCurrentUrl = "<%= data.searchUrlForJS %>";

          var curYear = <%= data.yearNum - 1991 %>;
          var curMonth = -1;
          var yearCount = 15;
          var firstYear = 1991;
          var startYear = <%= data.yearNum - 1991 %>;
          var imgWidth = <%= imgWidth %>;
          var yearImgWidth = <%= yearWidth %>;
          var monthImgWidth = <%= monthWidth %>;
          var trackerVal = "none";

          function showTrackers(val) {
            if (val == trackerVal) {
              return;
            }
            document.getElementById("wbMouseTrackYearImg").style.display = val;
            trackerVal = val;
          }
          function getElementX2(obj) {
            var thing = jQuery(obj);
            if ((thing == undefined)
                || (typeof thing == "undefined")
                || (typeof thing.offset == "undefined")) {
              return getElementX(obj);
            }
            return Math.round(thing.offset().left);
          }
          function setActiveYear(year) {
            if (curYear != year) {
              var yrOff = year * yearImgWidth;
              document.getElementById("wbMouseTrackYearImg").style.left = yrOff + "px";
              if (curYear != -1) {
              	document.getElementById("highlight-"+curYear).setAttribute("class","inactiveHighlight");
              }
              document.getElementById("highlight-"+year).setAttribute("class","activeHighlight");
              curYear = year;
            }
          }
          function trackMouseMove(event,element) {
            var eventX = getEventX(event);
            var elementX = getElementX2(element);
            var xOff = eventX - elementX;
            if (xOff < 0) {
              xOff = 0;
            } else if (xOff > imgWidth) {
              xOff = imgWidth;
            }
            var monthOff = xOff % yearImgWidth;
            var year = Math.floor(xOff / yearImgWidth);
            var yearStart = year * yearImgWidth;
            var monthOfYear = Math.floor(monthOff / monthImgWidth);
            if (monthOfYear > 11) {
              monthOfYear = 11;
            }
            var month = (year * 12) + monthOfYear;
            var day = 1;
            if (monthOff % 2 == 1) {
              day = 15;
            }
            var dateString =
              zeroPad(year + firstYear) +
              zeroPad(monthOfYear+1,2) +
              zeroPad(day,2) + "000000";

            var url = "<%= queryPrefix %>" + dateString + '*/' +  wbCurrentUrl;
            document.getElementById('wm-graph-anchor').href = url;
            setActiveYear(year);
          }
        </script>

        <script type="text/javascript">
          $().ready(function() {
            var tester = "none";
            $(".date").each(function(i) {
              var actualsize = $(this).find(".hidden").text();
              var size = actualsize * 12;
              var offset = size / 2;
              // set variable to add class to .date based on frequency count
              var frequencyClass = "none";
              // for dates with captures, assign appropriate classname value
              if (actualsize == 1) {frequencyClass = "low";}
              else if (actualsize == 2) {frequencyClass = "low";}
              else if (actualsize == 3) {frequencyClass = "low-medium";}
              else if (actualsize == 4) {frequencyClass = "low-medium";}
              else if (actualsize == 5) {frequencyClass = "medium";}
              else if (actualsize == 6) {frequencyClass = "medium";}
              else if (actualsize == 7) {frequencyClass = "medium-high";}
              else if (actualsize == 8) {frequencyClass = "medium-high";}
              else if (actualsize >= 9) {frequencyClass = "high";}
              // add class to .date so CSS will color appropriately
              $(this).addClass(frequencyClass);
            });
            $(".day a").each(function(i) {
              var dateClass = $(this).attr("class");
              var dateId = "#"+dateClass;
              $(this).hover(
                function() {$(dateId).removeClass("opacity20");},
                function() {$(dateId).addClass("opacity20");}
              );
            });
            $(".tooltip").bt({
              positions: ['top','right','left','bottom'],
              contentSelector: "$(this).find('.pop').html()",
              padding: 0,
              width: '130px',
              spikeGirth: 8,
              spikeLength: 8,
              overlap: 0,
              cornerRadius: 5,
              fill: '#efefef',
              strokeWidth: 1,
              strokeStyle: '#efefef',
              shadow: true,
              shadowColor: '#333',
              shadowBlur: 5,
              shadowOffsetX: 0,
              shadowOffsetY: 0,
              noShadowOpts: {strokeStyle:'#ccc'},
              hoverIntentOpts: {interval:60,timeout:3500},
              clickAnywhereToClose: true,
              closeWhenOthersOpen: true,
              windowMargin: 30,
              cssStyles: {
                fontSize: '12px',
                fontFamily: '"Arial","Helvetica Neue","Helvetica",sans-serif',
                lineHeight: 'normal',
                padding: '10px',
                color: '#333'
              }
            });

            var yrCount = $(".wbChartThisContainer").size();
            var yrTotal = <%= yearWidth %> * yrCount;
            var yrPad = (930 - yrTotal) / 2;
            $("#wbChartThis").css("padding-left",yrPad+"px");
          });
        </script>

      </div> <!-- end .col-sm-12 -->
    </div> <!-- end .row -->
  </div> <!-- end .container -->

</div> <!-- #main-container end -->

<!-- Closing tags below close tags opened in UI_header.jsp -->
      </div> <!-- #su-content end -->
    </div> <!-- #su-wrap end -->

<jsp:include page="/WEB-INF/template/UI-footer.jsp" flush="true" />
