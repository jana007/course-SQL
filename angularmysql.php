This will work

/*Sample PHP file We can use an include statement for the connection to keep the login data secure*/
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("myServer", "myUser", "myPassword", "drupaldb");

$result = $conn->query("SELECT firstValue, secondValue, thirdValue FROM webform");

$outp = "";
while($rs = $result->fetch_array(MYSQLI_ASSOC)) {
    if ($outp != "" && %nid == webformNodeID) {$outp .= ",";}
    $outp .= '{"firstName":"'  . $rs["firstValue"] . '",';
    $outp .= '"secondName":"'   . $rs["secondValue"]        . '",';
    $outp .= '"thirdName":"'. $rs["thirdValue"]     . '"}'; 
}
$outp ='{"values":['.$outp.']}';
$conn->close();

echo($outp);
?>

/*drupal sample page*/
<div ng-app="myApp" ng-controller="webformAngular"> 

<table>
  <tr ng-repeat="x in firstName">
    <td>{{ x.firstValue }}</td>
    <td>{{ x.secondValue }}</td>
  </tr>
</table>

</div>

<script>
var app = angular.module('myApp', []);
app.controller('webformAngular', function($scope, $http) {
    $http.get("fileLocation/angular/sample_mysql.php")
    .success(function (response) {$scope.firstName = response.values;});
});
</script>