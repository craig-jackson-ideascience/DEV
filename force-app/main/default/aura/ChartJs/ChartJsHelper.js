/**
 * Created by cloudroutesolutions on 20/01/21.
 */
({
	handleClick: function (component, evt) {
		var chart = component.get("v.chart");
		var activeElement = chart.getElementAtEvent(evt);
	},

	updateChartTicks: function (scale) {
		var incrementAmount = 0;
		var previousAmount = 0;
		var newTicks = [];
		newTicks = scale.ticks;
		for (x = 0; x < newTicks.length; x++) {
			incrementAmount = (previousAmount - newTicks[x]);
			previousAmount = newTicks[x];
		}
		if (newTicks.length > 2) {
			if (newTicks[0] - newTicks[1] != incrementAmount) {
				newTicks[0] = newTicks[1] + incrementAmount;
			}
		}
		return newTicks;
	},

	// //
	// Draw chart using chart.js.
	// If chart instance already exists, it will be destroyed and re-created.
	drawChart: function (component, chartData, chartOption) {

		// If Chart Type is not specified, apply default Chart Type
		var chartType = component.get("v.chartType");

		var chartColors = component.get("v.color");
		var chartPlugin = '';
		// Create Bar plug-in for ChartJS
		var originalLineDraw = Chart.controllers.bar.prototype.draw;
		Chart.helpers.extend(Chart.controllers.bar.prototype, {

			draw: function (chart) {
				originalLineDraw.apply(this, arguments);

				var chart = this.chart;
				var ctx = chart.chart.ctx;

				var index = chart.config.options.lineAtIndex;
				if (index) {

					var xaxis = chart.scales['x-axis-0'];
					var yaxis = chart.scales['y-axis-0'];

					var x1 = xaxis.getPixelForValue(index);
					var y1 = 0;

					var x2 = xaxis.getPixelForValue(index);
					var y2 = yaxis.height;

					ctx.save();
					ctx.beginPath();
					ctx.moveTo(x1, y1);
					ctx.strokeStyle = 'red';
					ctx.lineTo(x2, y2);
					ctx.stroke();

					ctx.restore();
				}
			}
		});

		// set background color for pie chart
		if (chartData.datasets != null && chartData.datasets.length > 0 && chartType == 'doughnut') {
			var colors = this.getDistributedColor(component, chartData.datasets.length, true);
			chartData.datasets[0].data = chartData.datasets[0].datainPercent;

			var colorArray = this.getChartColor(component, chartData.datasets[0].data.length);
			chartData.datasets[0].backgroundColor = colorArray;
			var currencyAmt = chartData.datasets[0].dataDougnutVal;
			var currencyVar = component.get('v.currency');

			chartPlugin = [{
				beforeInit: function (chart) {
					chart.data.labels.forEach(function (e, i, a) {
						if (/\n/.test(e)) {
							a[i] = e.split(/\n/);
						}
					});
				}
			}];
			chartOption = {
				responsive: component.get("v.IsPdf") == 'true' ? false : true,
				aspectRatio: 1,
				tooltips: { // Disable the on-canvas tooltip
					enabled: false,

					custom: function (tooltipModel) { // Tooltip Element
						var tooltipEl = document.getElementById('chartjs-tooltip');
						// Create element on first render
						if (!tooltipEl) {
							tooltipEl = document.createElement('div');
							tooltipEl.id = 'chartjs-tooltip';
							tooltipEl.innerHTML = '<table></table>';
							document.body.appendChild(tooltipEl);
						}

						// Hide if no tooltip
						if (tooltipModel.opacity === 0) {
							tooltipEl.style.opacity = 0;
							return;
						}

						// Set caret Position
						tooltipEl.classList.remove('above', 'below', 'no-transform');
						if (tooltipModel.yAlign) {
							tooltipEl.classList.add(tooltipModel.yAlign);
						} else {
							tooltipEl.classList.add('no-transform');
						}

						function getBody(bodyItem) {
							return bodyItem.lines;
						}

						// Set Text
						if (tooltipModel.body) {
							var titleLines = tooltipModel.title || [];
							var bodyLines = tooltipModel.body.map(getBody);

							var innerHtml = '<thead>';

							titleLines.forEach(function (title) {

								innerHtml += '<tr><th>' + title + '</th></tr>';
							});
							innerHtml += '</thead><tbody>';
							// doing logic over here
							//
							var map1 = new Map();
							var wrapperTemp = [];
							chartData.labels.forEach(function (body, i) {
								var title = chartData.labels[i];
								var percentValue = chartData.datasets[0].data[i];
								map1.set(percentValue, title);
								wrapperTemp.push({
									"label": chartData.labels[i],
									"percent": chartData.datasets[0].data[i],
									"data": chartData.datasets[0].dataDougnutVal[i],
									"backgroundColor": chartData.datasets[0].backgroundColor[i]
								})
							});
							wrapperTemp.sort(function (a, b) {
								return b.percent - a.percent;
							});
							// chartData.datasets[0].dataDougnutVal.sort(function(a, b){return b-a});
							wrapperTemp.forEach(function (body, i) {
								var colors = wrapperTemp[i].backgroundColor;
								var title = wrapperTemp[i].label;
								var percentValue = wrapperTemp[i].percent + '%';

								if (chartData.datasets[0].data[i] > 0) {
									var amountValue = Number(wrapperTemp[i].data).toLocaleString('de-CH', {
										style: 'currency',
										currency: currencyVar,
										maximumFractionDigits: 0,
										minimumFractionDigits: 0
									});
									var style = 'background:' + colors;
									style += '; border:1px solid white';
									style += '; padding:5px;padding-top:0px;padding-bottom:0px;';
									style += '; width: 5px';
									style += '; max-height: 1px';
									var span = '<span style="' + style + '"></span>';
									innerHtml += '<tr style="background-color:black;color:white;padding:8px;opacity = 1"><td style="padding-left:8px;padding-right:5px;"><b>' + title + '</b></td></tr>';
									innerHtml += '<tr style="background-color:black;color:white;8px;opacity = 1"><td style="padding-left:8px;padding-right:5px;">' + span + '<span style="margin-left:10px;">' + percentValue + '</span></td></tr>';
									innerHtml += '<tr style="background-color:black;color:white;8px;opacity = 1"><td style="padding-left:8px;padding-right:5px;">' + amountValue + '</td></tr>';
								}
							});
							innerHtml += '</tbody>';

							var tableRoot = tooltipEl.querySelector('table');
							tableRoot.innerHTML = innerHtml;
						}

						// `this` will be the overall tooltip
						var position = this._chart.canvas.getBoundingClientRect();

						// Display, position, and set styles for font
						tooltipEl.style.zIndex = "9999";
						tooltipEl.style.minWidth = "130px";
						tooltipEl.style.opacity = 1;
						tooltipEl.style.position = 'absolute';
						tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
						tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
						tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
						tooltipEl.style.fontSize = '12px';
						tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
						tooltipEl.style.padding = '10px';
						tooltipEl.style.pointerEvents = 'none';
					}
				},
				legendCallback: function (chart) {
					var text = [];
					text.push('<ul class="' + chart.id + '-legend' + ' chartjs-legend"');

					var data = chartData;
					var datasets = data.datasets;
					var labels = data.labels;

					if (datasets.length) {
						for (var i = 0; i < datasets[0].dataDougnutVal.length; ++i) {
							text.push('<li><span style="background-color:' + datasets[0].backgroundColor[i] + '"></span>');
							if (labels[i]) {
								text.push(labels[i] + ' (' + datasets[0].data[i] + '%)');
							}
							text.push('</li>');
						}
					}
					text.push('</ul>');
					return text.join('');
				},
				scaleLabel: {
					lineHeight: 1.2
				},
				legend: {
					display: component.get("v.showLegend"),
					position: 'right',
					labels: {
						fontSize: component.get("v.pdfFontSize") != '' ? component.get("v.pdfFontSize") : 50,
						fontFamily: 'Arial',
						generateLabels: function (chart) {
							chart.legend.afterFit = function () {
								if (component.get("v.showLegend") == true) {
									// this.width = 850;
									// this.options.labels.wordBreak = "break-all";
								}
								var width = this.width;
								this.lineWidths = 350;
								this.options.labels.padding = 20;
								this.options.labels.boxWidth = 50;
								this.options.labels.maxWidth = 350;
								this.options.labels.whiteSpace = "normal";
							};
							var data = chartData;
							var theHelp = Chart.helpers;
							if (data.labels.length && data.datasets.length) {
								return data.labels.map(function (label, i) {
									var meta = chart.getDatasetMeta(0);
									var ds = data.datasets[0];
									var arc = meta.data[i];
									var custom = arc && arc.custom || {};
									var getValueAtIndexOrDefault = theHelp.getValueAtIndexOrDefault;
									var arcOpts = chart.options.elements.arc;
									var fill = custom.backgroundColor ? custom.backgroundColor : getValueAtIndexOrDefault(ds.backgroundColor, i, arcOpts.backgroundColor);
									var stroke = custom.borderColor ? custom.borderColor : getValueAtIndexOrDefault(ds.borderColor, i, arcOpts.borderColor);
									var bw = custom.borderWidth ? custom.borderWidth : getValueAtIndexOrDefault(ds.borderWidth, i, arcOpts.borderWidth);
									return {
										text: label,
										fillStyle: fill,
										strokeStyle: stroke,
										lineWidth: bw,
										hidden: isNaN(ds.data[i]) || meta.data[i].hidden,
										index: i
									};
								});
							}
							return [];
						}
					}
				}
				/*hover: {
				        onHover: function(event,activeElements) {
				            alert('Hovered',activeElements);
				        }
				    }*/
			};
		} else if (chartData.datasets != null && chartData.datasets.length > 0 && (chartType == 'line' || chartType == 'bar')) {
			var chart = component.get("v.chart");
			if (chart != null) {
				chart.destroy();
			}
			var globalId = component.get("v.canvasId");
			var isStackedBar = component.get("v.isStackedBar");
			var isGroupedStackedBar = component.get("v.isGroupedStackedBar");
			// setTimeout(function(){
			var ctx = document.getElementById(globalId).getContext('2d');
			var showCustomValue = chartData.datasets[0].showCustomValue;
			var dataLength = chartData.labels.length;
			// chartData.labels.length;
			// Evaluation of value for the bar width
			var barPercentageValue = 0;
			if (dataLength == 1 || dataLength == 0) {
				barPercentageValue = 0.2;
			} else if (dataLength == 2) {
				barPercentageValue = 0.3;
			} else {
				barPercentageValue = 0.5;
			}
			if (isStackedBar) {
				var dataSetArry = [];
				component.set("v.message", chartData.message);
				component.set("v.reportURL", chartData.reportLink);
				chartData.datasets.forEach(function (data) {
					var dataInstance = {
						'label': data.label,
						'data': data.datainPercent,
						'backgroundColor': data.pointHighlightFill,
						'percentData': data.listOfPercentData,
						'mapOfXLabelVsStack': data.mapOfXLabelVsStack,
						'mapOfActiveMembers': data.mapOfActiveMembers
					};
					var dataInstanceString = JSON.parse(JSON.stringify(dataInstance));
					dataSetArry.push(dataInstanceString);
				});
				chartData = {
					labels: chartData.labels,
					datasets: dataSetArry,

					/* percentData: chartData.datasets[0].listOfPercentData */
				}
			} else if (isGroupedStackedBar) {
				var dataSetArry = [];
				component.set("v.message", chartData.message);
				component.set("v.reportURL", chartData.reportLink);
				var bgColor = chartData.datasets.forEach(function (data) {
					var dataInstance = {
						'label': data.label,
						'data': data.datainPercent,
						'backgroundColor': data.pointHighlightFill,
						'percentData': data.listOfPercentData,
						'mapOfXLabelVsStack': data.mapOfXLabelVsStack,
						'mapOfActiveMembers': data.mapOfActiveMembers,
						'stack': 1
					};
					var dataInstance2 = {
						'label': data.label,
						'data': data.cumulativeArray,
						'backgroundColor': data.pointHighlightFill,
						'percentData': data.listOfPercentData,
						'mapOfXLabelVsStack': data.mapOfXLabelVsStack,
						'mapOfActiveMembers': data.mapOfActiveMembers,
						'stack': 2
					};
					var dataInstanceString = JSON.parse(JSON.stringify(dataInstance));
					dataSetArry.push(dataInstanceString);
					var dataInstanceString2 = JSON.parse(JSON.stringify(dataInstance2));
					dataSetArry.push(dataInstanceString2);
				});
				chartData = {
					labels: chartData.labels,
					datasets: dataSetArry,
					datalabels: {
						align: 'end',
						anchor: 'end'
					}
					/* percentData: chartData.datasets[0].listOfPercentData */
				}
			} else { // Store overall sum of the data to display in tooltip
				var overAllSum = chartData.datasets[0].sumOfdata;

				chartData = {
					labels: chartData.labels,
					datasets: [{
						label: yAxisLabel, // "Sum of sales orders $",
						backgroundColor: "#52b7d8",
						hoverBackgroundColor: "rgba(50,90,100,1)",
						data: chartData.datasets[0].datainPercent,
						// contains percentage data for each data value
						percentData: chartData.datasets[0].listOfPercentData

					}]
				}
				/* chartData = {
				            labels: chartData.labels,
				            datasets: [
				                {
				                    label: chartData.datasets[0].label,
				                    /* backgroundColor: chartData.datasets[0].fillColor,
				                    /* backgroundColor: ["#52b7d8", "rgba(252, 123, 3)"], 
				                    data: chartData.datasets[0].datainPercent 
				                    data: chartData.datasets[0].datainPercent,//[727, 589, 537, 543, 574],
				                    backgroundColor: "#52b7d8"
				                    /* hoverBackgroundColor: "rgba(50,90,100,1)" 
				                }
				            ]
				        } */
			}
			var xAxisLabel = component.get("v.xAxisLabel");
			var yAxisLabel = component.get("v.yAxisLabel");
			var displayLegend = component.get("v.displayLegend");
			var scales = {
				yAxes: [{
					stacked: true,
					display: true,
					gridLines: { // invisible y-axis line
						drawBorder: false
					},
					scaleLabel: {
						display: true,
						labelString: yAxisLabel, // "Sum of sales orders $"
					},

					ticks: {
						// Abbreviate the millions
						/* stepSize: 1000000,
						                callback: function(value, index, values) {
						                    return value / 1e6 + 'M';
						                } */
						/* stepSize: chartData.datasets[0].stepSize,
						                /* maxTicksLimit: 2, 
						                callback: function (value, index, array) {
						                    //var valueInt = value.split('k');
						                    if (showCustomValue) {
						                        return (value < 1000000) ? value / 1000 + 'K' : value / 1000000 + 'M';
						                    } else {
						                        return value;
						                    }
						                } */

						/* stepSize: 10000, */
						maxTicksLimit: 10,
						callback: function (value, index, array) {
							if (showCustomValue) {
								return (value < 1000 ? value : value < 1000000 ? value / 1000 + 'K' : value / 1000000 + 'M');
							} else {
								return value;
							}
						},
						// suggestedMax: maxValue,///* Math.max(chartData.datasets[0].datainPercent),*/10000,
						suggestedMin: 0,
						beginAtZero: true

					}
				}],
				xAxes: [{
						// width of bar
						barPercentage: barPercentageValue,
						stacked: true,
						display: true,
						gridLines: {
							display: false
						},
						scaleLabel: {
							display: true,
							labelString: xAxisLabel // 'Days since Purchase Date'
						}
					},

				]
			};
			var year1 = '';
			var year2 = '';
			var currentMonth = '';
			var groupStackBarscales = {
				yAxes: [{
					stacked: true,
					display: true,
					gridLines: { // invisible y-axis line
						drawBorder: false
					},
					scaleLabel: {
						display: true,
						labelString: yAxisLabel, // "Sum of sales orders $"
					},
					ticks: {
						stepSize: 10000,
						maxTicksLimit: 18,
						callback: function (value, index, array) {
							if (showCustomValue) {
								return (value < 10000 ? value : value < 1000000 ? value / 1000 + 'K' : value / 1000000 + 'M');
							} else {
								return value;
							}
						},
						suggestedMin: 10000,
						beginAtZero: false

					}
				}],
				xAxes: [{
						// width of bar
						barPercentage: barPercentageValue,
						stacked: true,
						display: false,
						gridLines: {
							display: false
						},
						scaleLabel: {
							display: true,
							labelString: xAxisLabel // 'Days since Purchase Date'

						}
					}, {
						gridLines: {
							display: false
						},
						offset: true,
						id: 'xAxis1',
						type: "category",
						ticks: {
							callback: function (label) {
								var month = label.split("-")[0];
								var year = label.split("-")[1];
								return month;
							}
						}
					}, {
						id: 'xAxis2',
						offset: true,
						type: "category",
						gridLines: {
							display: false,
							drawOnChartArea: false, // only want the grid lines for one axis to show up
						},
						ticks: {
							callback: function (label) {
								var month = label.split("-")[0];
								var year = label.split("-")[1];
								if (year != year2) {
									currentMonth = month;
									year2 = year;
									return year2;
								} else {
									if (month == currentMonth) {
										return year2;
									} else {
										return '';
									}
									// return year1 == year2 ? year2 : '';
								}
							}
						}
					}

				]
			};

			chartOption = {
				responsive: true,
				legend: {
					display: displayLegend,
					position: 'bottom',
					align: 'center'
				},
				layout: {
					padding: {
						left: 5,
						right: 5,
						top: 5,
						bottom: 5
					}
				},
				elements: {
					line: {
						borderColor: '#1787EF',
						borderWidth: 1,
						cubicInterpolationMode: 'default',
						backgroundColor: 'rgba(255, 255, 255, 0.1)'
					},
					point: {
						radius: 2
					}
				},
				onClick: function (evt) { // this.handleClick(component)
					var activeElement = chart.getElementAtEvent(evt);
					for (var i = 0; i < this.data.datasets.length; i++) {
						this.getDatasetMeta(i).data.forEach(function (ele, idx) {
							if (ele.custom != undefined)
								delete ele.custom.backgroundColor;


							if (activeElement && activeElement.length > 0) {
								if (activeElement[0]._model.label == ele._model.label && activeElement[0]._model.datasetLabel == ele._model.datasetLabel) {
									ele.custom = ele.custom || {};
									ele.custom.backgroundColor = '#FFFF00';

								}
							}


						});
					}

					if (activeElement && activeElement.length > 0) {
						chart.update(true);
						var barValue = activeElement[0]._model.label;
						var yAxisValue = activeElement[0]._model.datasetLabel;
						// activeElement[0]._model.datasetLabel ?  activeElement[0]._model.datasetLabel :
						// fire component event to pass the value of clicked bar
						var cmpEvent = component.getEvent("chartClickEvent");
						cmpEvent.setParams({
							"clickedValue": barValue,
							"yAxisValue": yAxisValue
						});
						cmpEvent.fire();
					}

				},

			}

			var animation = {
				/* duration: 1,*/
				onComplete: function () {
					var chartInstance = this.chart,
						ctx = chartInstance.ctx;
					ctx.textAlign = 'center';
					ctx.fillStyle = "rgba(0, 0, 0, 1)";
					ctx.textBaseline = 'bottom';
					// Loop through each data in the datasets
					this.data.datasets.forEach(function (dataset, i) {
						var meta = chartInstance.controller.getDatasetMeta(i);
						meta.data.forEach(function (bar, index) {
							var value = dataset.data[index];
							var data = (value < 1000000) ? Math.round(value / 1000) : (value / 1000000).toFixed(1);
							var roundedData = data // Math.ceil(Math.round(data));
							var roundOffValue = (value < 1000000) ? roundedData + 'K' : roundedData + 'M';
							ctx.fillText(roundOffValue, bar._model.x, bar._model.y + 15);
						});
					});
				}
			};

			var tooltips = {
				enabled: true,
				xPadding: 10,
				yPadding: 10,
				footerSpacing: 2,
				backgroundColor: 'rgba(0, 0, 80, 0.8)',
				callbacks: {
					label: function (tooltipItem, data) {

						var label = data.datasets[tooltipItem.datasetIndex].label || '';
						if (label) {
							label += ' ';
						}
						var numberValue = Math.round(tooltipItem.yLabel * 100) / 100;
						// append comma seperated number
						label += numberValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

						return label;
					},

					beforeTitle: function (tooltipItem) {
						return "Days";
					},

					// to have horizontal line in tooltip
					afterTitle: function (tooltipItem) {
						var label1 = '_';
						var i;
						for (i = 0; i <= 35; i++) {
							label1 += '_';
						}

						return label1;
					},


					// footer of tooltip
					footer: function (tooltipItem, data) {
						var percentageData = data.datasets[tooltipItem[0].datasetIndex].percentData[parseInt(tooltipItem[0].xLabel)];

						// Rounding off overall sum
						var data = (overAllSum < 1000000) ? overAllSum / 1000 : overAllSum / 1000000;
						var roundedData = Math.ceil(Math.round(data));
						var roundOffoverAllSum = (roundedData < 1000000) ? roundedData + 'K' : roundedData + 'M';

						// Rounding to two decimal place for percentage
						var roundOfpercentageData = percentageData % 1 != 0 ? percentageData.toFixed(2) : percentageData;
						return [
							'',
							"(" + roundOfpercentageData + "% of " + roundOffoverAllSum + ")"
						];
					}
				}
			}
			var indexVar = 0;
			var stackBarTooltip = {
				enabled: true,
				xPadding: 10,
				yPadding: 10,
				footerSpacing: 2,
				backgroundColor: 'rgba(0, 0, 80, 0.8)',
				callbacks: {
					label: function (tooltipItem, data) {

						var label = data.datasets[tooltipItem.datasetIndex].label || '';
						if (label) {
							label += ' ';
						}
						var numberValue = Math.round(tooltipItem.yLabel * 100) / 100;
						// append comma seperated number
						label += numberValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

						return label;
					},

					beforeTitle: function (tooltipItem) {
						return "Created Date(month)";
					},

					// to have horizontal line in tooltip
					afterTitle: function (tooltipItem) {
						var label1 = '_';
						var i;
						for (i = 0; i <= 35; i++) {
							label1 += '_';
						}

						return label1;
					},


					// footer of tooltip
					footer: function (tooltipItem, data) {
						var month = tooltipItem[0].xLabel;
						var prodName = data.datasets[tooltipItem[0].datasetIndex].label;
						var status = data.datasets[tooltipItem[0].datasetIndex].label;
						var percentData = data.datasets[0].percentData[month + '-' + status];
						var total = data.datasets[0].mapOfXLabelVsStack[month];
						var displayFooter = '';
						if (data.datasets[0].mapOfActiveMembers != null) {
							var activeMembers = data.datasets[0].mapOfActiveMembers[month + '-' + prodName];
							if (activeMembers > 0) {
								displayFooter = "Active Members " + activeMembers + "\n" + percentData.toFixed(2) + "% of " + total + " for " + month;
							} else {
								displayFooter = percentData.toFixed(2) + "% of " + total + " for " + month;
							}
						} else {
							displayFooter = percentData.toFixed(2) + "% of " + total + " for " + month;
						}
						return displayFooter;
					}
				}
			}

			var groupStackBarTooltip = {
				enabled: true,
				xPadding: 10,
				yPadding: 10,
				footerSpacing: 2,
				backgroundColor: 'rgba(0, 0, 80, 0.8)',
				callbacks: {
					label: function (tooltipItem, data) {

						var label = data.datasets[tooltipItem.datasetIndex].label || '';
						if (label) {
							label += ' ';
						}
						var numberValue = Math.round(tooltipItem.yLabel * 100) / 100;
						// append comma seperated number
						label += numberValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");

						return label;
					},

					beforeTitle: function (tooltipItem) {
						return "Install Date(Year)";
					},

					// to have horizontal line in tooltip
					afterTitle: function (tooltipItem) {
						var label1 = '_';
						var i;
						for (i = 0; i <= 35; i++) {
							label1 += '_';
						}

						return label1;
					},


					// footer of tooltip
					footer: function (tooltipItem, data) {
						var month = tooltipItem[0].xLabel;
						var prodName = data.datasets[tooltipItem[0].datasetIndex].label;
						var percentData = data.datasets[0].percentData[month + '-' + prodName];
						var total = data.datasets[0].mapOfXLabelVsStack[month + '-' + prodName];
						var activeMembers = data.datasets[0].mapOfActiveMembers[month + '-' + prodName];
						var displayFooter = '';
						if (activeMembers > 0) {
							displayFooter = "Active Members " + activeMembers + "\n" + percentData.toFixed(2) + "% of " + total + " for " + month;
						} else {
							displayFooter = percentData.toFixed(2) + "% of " + total + " for " + month;
						}
						return displayFooter;
					}
				}
			}
			var animationGroupStack = {
				onComplete: function () {
					var chartInstance = this.chart,
						ctx = chartInstance.ctx;
					ctx.textAlign = 'center';
					ctx.fillStyle = "rgba(0, 0, 0, 1)";
					ctx.textBaseline = 'bottom';
					var sums = [0, 0, 0];
					var dataSetLength = this.data.datasets.length;
					var totalDataSet = 0;
					this.data.datasets.forEach(function (dataset, i) {
						var meta = chartInstance.controller.getDatasetMeta(i);
						meta.data.forEach(function (bar, index) {
							totalDataSet = bar._datasetIndex;
						});


					});
					this.data.datasets.forEach(function (dataset, i) {
						var meta = chartInstance.controller.getDatasetMeta(i);
						meta.data.forEach(function (bar, index) {
							var value = dataset.data[index];
							sums[index] += value;
							var data = (value < 1000000) ? Math.round(value / 1000) : (value / 1000000).toFixed(1);
							var roundedData = data // Math.ceil(Math.round(data));
							var roundOffValue = (value < 1000000) ? roundedData + 'K' : roundedData + 'M';
							if (bar._datasetIndex == totalDataSet) {
								ctx.fillText(roundOffValue, bar._model.x, bar._model.y);
							}
						});
					});

				}
			}

			var plugins = {
				datalabels: {
					formatter: (value, ctx) => {

						let datasets = ctx.chart.data.datasets.filter(ds => {
							return !ds._meta[0].hidden
						});

						if (datasets.indexOf(ctx.dataset) === datasets.length - 1) {
							let sum = 0;
							datasets.map(dataset => {
								sum += dataset.data[ctx.dataIndex];
							});
							return sum.toLocaleString('fr-FR', {
								style: 'currency',
								currency: 'EUR'
							});
						} else {
							return '';
						}
					},
					anchor: 'end',
					align: 'end'
				}
			}

			if (!isStackedBar && !isGroupedStackedBar) {
				chartOption.animation = animation;
				chartOption.tooltips = tooltips;
				chartOption.scales = scales;
			} else if (isStackedBar) {
				chartOption.tooltips = stackBarTooltip;
				chartOption.scales = scales;
			} else if (isGroupedStackedBar) {
				chartOption.tooltips = groupStackBarTooltip;
				chartOption.scales = groupStackBarscales;
			}


			if (window.myCharts != undefined)
				window.myCharts.destroy();



			var lineChart = new Chart(ctx, {
				type: chartType,
				data: chartData,
				options: chartOption
			});

			component.set("v.chart", lineChart);
			component.set("v.chartData", chartData);
			component.set("v.chartOption", chartOption);

			// }, 3000);


		} else {
			if (chartData.datasets != null && chartData.datasets.length > 0) {
				var colors = this.getDistributedColor(component, chartData.datasets.length, true);
				if (!$A.util.isUndefinedOrNull(chartColors)) {
					var colorArray = this.getChartColorBar(component, chartData.datasets[0].data.length, chartColors);
					chartData.datasets[0].backgroundColor = colorArray;
					var currencyVar = component.get('v.currency');
					chartOption = {
						lineAtIndex: 0,
						responsive: true,
						scales: {
							yAxes: [{
								id: 'y-axis-1',
								display: true,
								position: 'left',
								ticks: {
									beginAtZero: true,
									callback: function (value, index, values) {
										return Number(value).toLocaleString('de-CH'); // , { style: 'currency', currency: currencyVar });
									}

								}
							}],
							xAxes: [{
								barPercentage: 0.5,
								barThickness: 13,
								maxBarThickness: 13,
								minBarLength: 3,
								offset: true,
							}]
						},
						annotation: {
							annotations: [{
								type: 'line',
								mode: 'vertical',
								scaleID: 'x-axis-0',
								value: 0,
								borderColor: 'tomato',
								borderWidth: 1
							}],
							drawTime: "afterDraw" // (default)
						},
						tooltips: {
							mode: 'index',
							axis: 'x',
							callbacks: {
								title: function (tooltipItem, data) {
									if (data['datasets'][0]['dataLabelBar'].length > 0) {
										return data['datasets'][0]['dataLabelBar'][tooltipItem[0]['index']];
									} else {
										return data['labels'][tooltipItem[0]['index']];
									}
								},
								label: function (tooltipItem, data) {
									return Number(data['datasets'][0]['data'][tooltipItem['index']]).toLocaleString('de-CH', {
										style: 'currency',
										currency: currencyVar,
										maximumFractionDigits: 0,
										minimumFractionDigits: 0
									});
								}

							}
						},
						legend: {
							display: component.get("v.showLegend")
						},
						layout: {
							padding: {
								left: 0,
								bottom: 10
							}
						}
					};
				}
			}
			if (component.get("v.IsPdf") == 'true' && chartData.datasets[0].dataLabelBar.length > 0) {
				chartData.labels = chartData.datasets[0].dataLabelBar;
			}
		}
		// If chart already exists, we destroy it first and re-create to clean the state.
		var chart = component.get("v.chart");
		if (chart != null) {
			chart.destroy();
		}

		// Draw chart.
		var globalId = component.get("v.canvasId");

		var ctx = document.getElementById(globalId).getContext("2d");
		ctx.fillStyle = "blue";

		if (component.get("v.IsPdf") == 'true') {
			Chart.defaults.global.defaultFontSize = 12;
			Chart.defaults.global.defaultFontFamily = 'Arial';
		} else {
			Chart.defaults.global.defaultFontSize = 12;
		}
		chart = new Chart(ctx, {
			type: chartType,
			data: chartData,
			options: chartOption
		});
		// Save chart instance, chart data and chart option so that we can refer them afterward. Ex. Those properties are refered when chart type is changed.
		component.set("v.chart", chart);
		component.set("v.chartData", chartData);
		component.set("v.chartOption", chartOption);
	},


	// //
	// Return the default color based on the available chart types.
	getDefaultChartTypeByAvailableChartTypeList: function (component, availableChartTypeList) {
		return availableChartTypeList[0].name;
	},
	// //
	// Method to generate distributed colors for charts.
	// If chart data does not contain color or fillColor property, this method is called and try to set all colors automatically.
	getDistributedColor: function (component, input, thin) {
		var r = 0x0;
		var g = 0x0;
		var b = 0x0;
		var thin_plus = (thin) ? 1 : 0;
		var colors_array = new Array();
		for (var i = 0;; i++) {
			if (Math.pow(i, 3) >= input) {
				var max = i - 1 + thin_plus;
				break;
			}
		}

		var _plus = (max == 1) ? 0xff / 2 : 0xff / max;
		for (var i = thin_plus; i <= max; i++) {
			r = _plus * i;
			g = 0x0;
			b = 0x0;
			for (var j = thin_plus; j <= max; j++) {
				g = _plus * j;
				b = 0x0;
				for (var k = thin_plus; k <= max; k++) {
					b = _plus * k;
					colors_array.push([Math.round(r), Math.round(g), Math.round(b)]);
					if (colors_array.length >= input)
						return colors_array;



				}
				if (colors_array.length >= input)
					return colors_array;



			}
			if (colors_array.length >= input)
				return colors_array;



		}
	},

	getChartColor: function (component, chartData) {
		var colorArray = [];
		var colorListArray = [
			"#1787ef",
			"#0f4577",
			"#06cfe9",
			"#9d63ff",
			"#ff4d73",
			"#fcae52",
			"#04cd7a",
			"#AFD6FA",
			"#0A5BA6",
			"#068697"
		];
		var colors = '';
		for (var i = 0; i < chartData; i++) {
			colorArray.push(colorListArray[i]);
			// colorArray.push('rgb(' + (Math.floor(Math.random() * 256)) + ',' + (Math.floor(Math.random() * 256)) + ',' + (Math.floor(Math.random() * 256)));
			// colors += (Math.floor(Math.random() * 256)) +','+ (Math.floor(Math.random() * 256)) +','+  (Math.floor(Math.random() * 256));
			// colorArray.push((Math.floor(Math.random() * 256)) , (Math.floor(Math.random() * 256)) , (Math.floor(Math.random() * 256)));
		}
		// colorArray.push(colors);
		return colorArray;

	},

	getChartColorBar: function (component, chartData, chartColors) {
		var chartColorsArray = chartColors.split(",");
		var colorArray = [];
		var colors = '';
		for (var i = 0; i < chartData; i++) {
			var temp = this.evenOddFunc(i)
			if (temp == 1) {
				colorArray.push(chartColorsArray[1]);
			} else {
				colorArray.push(chartColorsArray[0]);
			}

			// colors += (Math.floor(Math.random() * 256)) +','+ (Math.floor(Math.random() * 256)) +','+  (Math.floor(Math.random() * 256));
			// colorArray.push((Math.floor(Math.random() * 256)) , (Math.floor(Math.random() * 256)) , (Math.floor(Math.random() * 256)));
		}
		// colorArray.push(colors);
		return colorArray;
	},

	evenOddFunc: function (numberVal) {
		return numberVal % 2;
	},

	prepareStackGroupBarChart: function (component) {
		Chart.defaults.groupableBar = Chart.helpers.clone(Chart.defaults.bar);

		var helpers = Chart.helpers;
		Chart.controllers.groupableBar = Chart.controllers.bar.extend({
			calculateBarX: function (index, datasetIndex) { // position the bars based on the stack index
				var stackIndex = this.getMeta().stackIndex;
				return Chart.controllers.bar.prototype.calculateBarX.apply(this, [index, stackIndex]);
			},

			hideOtherStacks: function (datasetIndex) {
				var meta = this.getMeta();
				var stackIndex = meta.stackIndex;

				this.hiddens = [];
				for (var i = 0; i < datasetIndex; i++) {
					var dsMeta = this.chart.getDatasetMeta(i);
					if (dsMeta.stackIndex !== stackIndex) {
						this.hiddens.push(dsMeta.hidden);
						dsMeta.hidden = true;
					}
				}
			},

			unhideOtherStacks: function (datasetIndex) {
				var meta = this.getMeta();
				var stackIndex = meta.stackIndex;

				for (var i = 0; i < datasetIndex; i++) {
					var dsMeta = this.chart.getDatasetMeta(i);
					if (dsMeta.stackIndex !== stackIndex) {
						dsMeta.hidden = this.hiddens.unshift();
					}
				}
			},

			calculateBarY: function (index, datasetIndex) {
				this.hideOtherStacks(datasetIndex);
				var barY = Chart.controllers.bar.prototype.calculateBarY.apply(this, [index, datasetIndex]);
				this.unhideOtherStacks(datasetIndex);
				return barY;
			},

			calculateBarBase: function (datasetIndex, index) {
				this.hideOtherStacks(datasetIndex);
				var barBase = Chart.controllers.bar.prototype.calculateBarBase.apply(this, [datasetIndex, index]);
				this.unhideOtherStacks(datasetIndex);
				return barBase;
			},

			getBarCount: function () {
				var stacks = [];

				// put the stack index in the dataset meta
				Chart.helpers.each(this.chart.data.datasets, function (dataset, datasetIndex) {
					var meta = this.chart.getDatasetMeta(datasetIndex);
					if (meta.bar && this.chart.isDatasetVisible(datasetIndex)) {
						var stackIndex = stacks.indexOf(dataset.stack);
						if (stackIndex === -1) {
							stackIndex = stacks.length;
							stacks.push(dataset.stack);
						}
						meta.stackIndex = stackIndex;
					}
				}, this);

				this.getMeta().stacks = stacks;
				return stacks.length;
			}
		});
	}

})