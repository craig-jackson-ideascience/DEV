({
	/* draw chart */
	drawChart: function (component, chartData) {
		/* tooltip */

		var tooltip = {
			enabled: true,
			xPadding: 10,
			yPadding: 10,
			footerSpacing: 2,
			backgroundColor: 'rgba(0, 0, 80, 0.8)',
			callbacks: {
				label: function (tooltipItem, data) {
					var label = data.labels[tooltipItem.index] || '';

					return label;
				},

				beforeTitle: function (tooltipItem) {
					return "OpportunityId.StageName";
				},

				/* to have horizontal line in tooltip */
				afterTitle: function (tooltipItem) {
					var label1 = '_';
					var i;
					for (i = 0; i <= 30; i++) {
						label1 += '_';
					}
					return label1;
				},


				/* footer of tooltip */
				footer: function (tooltipItem, data) {
					var tooltipMap = data.datasets[0].tooltipMap;
					var mapOfEventVsTotal = data.datasets[0].mapOfEventVsTotal;
					var label = data.labels[tooltipItem[0].index];
					var displayFooter = 'Sum of Total Price';
					var numberValue = data.datasets[0].data[tooltipItem[0].index];
					var eventName = data.datasets[0].eventName;
					var total = mapOfEventVsTotal[eventName];
					var data = (total < 1000000) ? Math.round(total / 1000) : (total / 1000000).toFixed(1);
					var roundedData = data // Math.ceil(Math.round(data));
					var roundOffValue = (total < 1000000) ? roundedData + 'K' : roundedData + 'M';
					var percentVal = tooltipMap[label].toFixed(2) + "% of $" + roundOffValue;
					/* to show comma seperated */
					displayFooter += ' $' + numberValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
					var displayFooter1 = '(' + percentVal + ')';
					return [displayFooter, displayFooter1];
				}
			}
		}

		/* configuration options */
		var maxValue = Math.min(chartData.listOfTotalPrice);
		var config = {
			type: 'doughnut',
			data: {
				datasets: [{
					data: chartData.listOfTotalPrice,
					eventName: chartData.eventName,
					tooltipMap: chartData.tooltipMap,
					mapOfEventVsTotal: chartData.mapOfEventVsTotal,
					backgroundColor: chartData.listOfColor //["#FF6384", "#36A2EB", "#FFCE56", "#00b3b4", "#e84340"]
				}],
				labels: chartData.listOfStageName
			},
			options: {
				responsive: true,
				tooltips: tooltip,
				topWidth: 100,
				gap: 0,
				sort: 'desc',
				/*to show reverse chart*/
				legend: {
					position: 'right' /* show legends on right side */
				},
				onClick: function (evt) { // handleClick

					component.set("v.showSpinner", true);
					var chartArray = component.get("v.selectedChart") != null ? component.get("v.selectedChart") : [];
					var chartId = component.get("v.canvasId");
					var chart = component.get("v.chart");
					var activeElement = chart.getElementAtEvent(evt);

					var beforeColor, eventStage = '';
					var addArrayInstance = true;
					if (activeElement && activeElement.length > 0) {
						beforeColor = activeElement[0]._model.backgroundColor;
						for (var i = 0; i < this.data.datasets.length; i++) {
							this.getDatasetMeta(i).data.forEach(function (ele, idx) {
								if (ele.custom != undefined)
									delete ele.custom.backgroundColor;
								if (activeElement && activeElement.length > 0) {
									if (activeElement[0]._model.label == ele._model.label) {
										ele.custom = ele.custom || {};
										var bgColor = '#39FF14';
										chartArray.forEach(element => {
											if (element.chart == chartId + activeElement[0]._model.label) {
												if (element.eventStage == chartId + activeElement[0]._model.label + ' customColor') {
													bgColor = element.chartColor;
                                                    element.eventStage = '';
													element.selectedHighlightColor = false;
												} else {
													bgColor = '#39FF14';
                                                    element.eventStage = chartId + activeElement[0]._model.label + ' customColor';
													element.selectedHighlightColor = true;
												}
												chartArray.splice[0, 1];
												addArrayInstance = false;
											}
										});
										activeElement[0].custom.backgroundColor = bgColor;
									}
								}
							});
						}
					}
					if (activeElement && activeElement.length > 0) {
						chart.update(true);
						var stageName = activeElement[0]._model.label;
						var cmpEvent = component.getEvent("funnelChartClickEvent");
						chartArray = [];
						if (addArrayInstance) {
							var selectedChartInstance = {};
							selectedChartInstance.chart = chartId + activeElement[0]._model.label;
							selectedChartInstance.chartColor = beforeColor;
							selectedChartInstance.selectedHighlightColor = true;
							selectedChartInstance.eventStage = chartId + activeElement[0]._model.label + ' customColor';
							chartArray.push(selectedChartInstance);
							component.set("v.selectedChart", JSON.parse(JSON.stringify(chartArray)));
						}
						cmpEvent.setParams({
							"clickedValue": stageName,
							"chartId": chartId
						});
						cmpEvent.fire();
					}
					component.set("v.showSpinner", false);

				},
				animation: {
					animateScale: true,
					animateRotate: true
				}
			}

		}


		/* get id, draw and show chart */
		var globalId = component.get("v.canvasId");
		var ctx = document.getElementById(globalId).getContext('2d');
		var funnelChart = new Chart(ctx, config);
		component.set("v.chart", funnelChart);
		component.set("v.showSpinner", false);
	}
})