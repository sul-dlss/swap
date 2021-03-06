<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.getGeneric(request);
StringFormatter fmt = results.getWbRequest().getFormatter();

String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();
%>
    <!-- Stanford global footer snippet start -->
    <div id="global-footer">
      <div class="container">
        <div class="row">
          <div id="bottom-logo" class="span2">
            <a href="http://www.stanford.edu">
              <img src="https://www.stanford.edu/su-identity/images/footer-stanford-logo@2x.png" alt="Stanford University" width="105" height="49"/>
            </a>
          </div>
          <!-- #bottom-logo end -->
          <div id="bottom-text" class="span10">
            <ul>
              <li class="home">
                <a href="http://www.stanford.edu">SU Home</a>
              </li>
              <li class="maps alt">
                <a href="http://visit.stanford.edu/plan/maps.html">Maps &amp; Directions</a>
              </li>
              <li class="search-stanford">
                <a href="http://www.stanford.edu/search/">Search Stanford</a>
              </li>
              <li class="terms alt">
                <a href="http://www.stanford.edu/site/terms.html">Terms of Use</a>
              </li>
              <li class="emergency-info">
                <a href="http://emergency.stanford.edu">Emergency Info</a>
              </li>
            </ul>
          </div> <!-- .bottom-text end -->
          <div class="clear"></div>
          <p class="copyright vcard">&copy; <span class="fn org">Stanford University</span>, <span class="adr"> <span class="locality">Stanford</span>, <span class="region">California</span> <span class="postal-code">94305</span> </span>
            <span id="copyright-complaint">
              <a href="http://www.stanford.edu/group/security/dmca.html" class="copyright-complaint" >Copyright Complaints</a>
            </span>
          </p>
        </div> <!-- .row end -->
      </div> <!-- .container end -->
    </div> <!-- global-footer end -->
    <!-- Global footer snippet end -->

  </body>
</html>
