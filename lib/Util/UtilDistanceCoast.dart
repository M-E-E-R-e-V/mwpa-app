import 'dart:ffi';

import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';

class UtilDistanceCoast {

  // https://www.geoplaner.de/
  // https://pub.dev/packages/gpx

  static Gpx xmlGpx = GpxReader().fromString('''<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
  <gpx version="1.1" creator="http://www.geoplaner.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
  <wpt lat="28.08153" lon="-17.33033">
  <name>WP01-A</name>
  </wpt>
  <wpt lat="28.081" lon="-17.32985">
  <name>WP02-B</name>
  </wpt>
  <wpt lat="28.08055" lon="-17.329">
  <name>WP03-C</name>
  </wpt>
  <wpt lat="28.08028" lon="-17.32839">
  <name>WP04-D</name>
  </wpt>
  <wpt lat="28.08017" lon="-17.32715">
  <name>WP05-E</name>
  </wpt>
  <wpt lat="28.08002" lon="-17.32646">
  <name>WP06-F</name>
  </wpt>
  <wpt lat="28.08024" lon="-17.32565">
  <name>WP07-G</name>
  </wpt>
  <wpt lat="28.0799" lon="-17.32487">
  <name>WP08-H</name>
  </wpt>
  <wpt lat="28.07934" lon="-17.32389">
  <name>WP09-I</name>
  </wpt>
  <wpt lat="28.07847" lon="-17.32329">
  <name>WP10-J</name>
  </wpt>
  <wpt lat="28.07767" lon="-17.32281">
  <name>WP11-K</name>
  </wpt>
  <wpt lat="28.07676" lon="-17.32204">
  <name>WP12-L</name>
  </wpt>
  <wpt lat="28.07642" lon="-17.32135">
  <name>WP13-M</name>
  </wpt>
  <wpt lat="28.07616" lon="-17.32062">
  <name>WP14-N</name>
  </wpt>
  <wpt lat="28.07535" lon="-17.32025">
  <name>WP15-O</name>
  </wpt>
  <wpt lat="28.07468" lon="-17.31998">
  <name>WP16-P</name>
  </wpt>
  <wpt lat="28.0743" lon="-17.31985">
  <name>WP17-Q</name>
  </wpt>
  <wpt lat="28.07381" lon="-17.31955">
  <name>WP18-R</name>
  </wpt>
  <wpt lat="28.07343" lon="-17.31942">
  <name>WP19-S</name>
  </wpt>
  <wpt lat="28.07283" lon="-17.31938">
  <name>WP20-T</name>
  </wpt>
  <wpt lat="28.07241" lon="-17.31929">
  <name>WP21-U</name>
  </wpt>
  <wpt lat="28.07218" lon="-17.31904">
  <name>WP22-V</name>
  </wpt>
  <wpt lat="28.07158" lon="-17.31878">
  <name>WP23-W</name>
  </wpt>
  <wpt lat="28.07128" lon="-17.31895">
  <name>WP24-X</name>
  </wpt>
  <wpt lat="28.07097" lon="-17.31916">
  <name>WP25-Y</name>
  </wpt>
  <wpt lat="28.07078" lon="-17.31904">
  <name>WP26-Z</name>
  </wpt>
  <wpt lat="28.07048" lon="-17.31882">
  <name>WP27</name>
  </wpt>
  <wpt lat="28.07025" lon="-17.31852">
  <name>WP28</name>
  </wpt>
  <wpt lat="28.0698" lon="-17.31856">
  <name>WP29</name>
  </wpt>
  <wpt lat="28.0695" lon="-17.31856">
  <name>WP30</name>
  </wpt>
  <wpt lat="28.06893" lon="-17.31843">
  <name>WP31</name>
  </wpt>
  <wpt lat="28.0687" lon="-17.31861">
  <name>WP32</name>
  </wpt>
  <wpt lat="28.06821" lon="-17.31869">
  <name>WP33</name>
  </wpt>
  <wpt lat="28.06802" lon="-17.31908">
  <name>WP34</name>
  </wpt>
  <wpt lat="28.06768" lon="-17.31938">
  <name>WP35</name>
  </wpt>
  <wpt lat="28.06719" lon="-17.32007">
  <name>WP36</name>
  </wpt>
  <wpt lat="28.067" lon="-17.32015">
  <name>WP37</name>
  </wpt>
  <wpt lat="28.06673" lon="-17.31985">
  <name>WP38</name>
  </wpt>
  <wpt lat="28.06617" lon="-17.31989">
  <name>WP39</name>
  </wpt>
  <wpt lat="28.06583" lon="-17.32002">
  <name>WP40</name>
  </wpt>
  <wpt lat="28.06545" lon="-17.32011">
  <name>WP41</name>
  </wpt>
  <wpt lat="28.06507" lon="-17.32054">
  <name>WP42</name>
  </wpt>
  <wpt lat="28.06495" lon="-17.32092">
  <name>WP43</name>
  </wpt>
  <wpt lat="28.06465" lon="-17.32071">
  <name>WP44</name>
  </wpt>
  <wpt lat="28.06435" lon="-17.32075">
  <name>WP45</name>
  </wpt>
  <wpt lat="28.0642" lon="-17.32037">
  <name>WP46</name>
  </wpt>
  <wpt lat="28.06401" lon="-17.32002">
  <name>WP47</name>
  </wpt>
  <wpt lat="28.06363" lon="-17.31998">
  <name>WP48</name>
  </wpt>
  <wpt lat="28.06359" lon="-17.31977">
  <name>WP49</name>
  </wpt>
  <wpt lat="28.06348" lon="-17.31959">
  <name>WP50</name>
  </wpt>
  <wpt lat="28.06333" lon="-17.31908">
  <name>WP51</name>
  </wpt>
  <wpt lat="28.06333" lon="-17.31908">
  <name>WP52</name>
  </wpt>
  <wpt lat="28.0631" lon="-17.31882">
  <name>WP53</name>
  </wpt>
  <wpt lat="28.06291" lon="-17.31865">
  <name>WP54</name>
  </wpt>
  <wpt lat="28.06249" lon="-17.31891">
  <name>WP55</name>
  </wpt>
  <wpt lat="28.06227" lon="-17.31882">
  <name>WP56</name>
  </wpt>
  <wpt lat="28.06208" lon="-17.31904">
  <name>WP57</name>
  </wpt>
  <wpt lat="28.06178" lon="-17.31916">
  <name>WP58</name>
  </wpt>
  <wpt lat="28.0614" lon="-17.31955">
  <name>WP59</name>
  </wpt>
  <wpt lat="28.06098" lon="-17.31951">
  <name>WP60</name>
  </wpt>
  <wpt lat="28.06041" lon="-17.31959">
  <name>WP61</name>
  </wpt>
  <wpt lat="28.05992" lon="-17.31947">
  <name>WP62</name>
  </wpt>
  <wpt lat="28.05958" lon="-17.31934">
  <name>WP63</name>
  </wpt>
  <wpt lat="28.05935" lon="-17.31904">
  <name>WP64</name>
  </wpt>
  <wpt lat="28.05882" lon="-17.31938">
  <name>WP65</name>
  </wpt>
  <wpt lat="28.05818" lon="-17.31998">
  <name>WP66</name>
  </wpt>
  <wpt lat="28.05761" lon="-17.32024">
  <name>WP67</name>
  </wpt>
  <wpt lat="28.05761" lon="-17.31977">
  <name>WP68</name>
  </wpt>
  <wpt lat="28.0586" lon="-17.31904">
  <name>WP69</name>
  </wpt>
  <wpt lat="28.05882" lon="-17.31831">
  <name>WP70</name>
  </wpt>
  <wpt lat="28.05935" lon="-17.3177">
  <name>WP71</name>
  </wpt>
  <wpt lat="28.05988" lon="-17.31693">
  <name>WP72</name>
  </wpt>
  <wpt lat="28.05943" lon="-17.3165">
  <name>WP73</name>
  </wpt>
  <wpt lat="28.05939" lon="-17.31607">
  <name>WP74</name>
  </wpt>
  <wpt lat="28.0592" lon="-17.3159">
  <name>WP75</name>
  </wpt>
  <wpt lat="28.05879" lon="-17.3156">
  <name>WP76</name>
  </wpt>
  <wpt lat="28.05822" lon="-17.31504">
  <name>WP77</name>
  </wpt>
  <wpt lat="28.0578" lon="-17.31496">
  <name>WP78</name>
  </wpt>
  <wpt lat="28.05735" lon="-17.31449">
  <name>WP79</name>
  </wpt>
  <wpt lat="28.05742" lon="-17.31384">
  <name>WP80</name>
  </wpt>
  <wpt lat="28.05712" lon="-17.31354">
  <name>WP81</name>
  </wpt>
  <wpt lat="28.05693" lon="-17.31333">
  <name>WP82</name>
  </wpt>
  <wpt lat="28.05633" lon="-17.3132">
  <name>WP83</name>
  </wpt>
  <wpt lat="28.0558" lon="-17.31298">
  <name>WP84</name>
  </wpt>
  <wpt lat="28.05519" lon="-17.31277">
  <name>WP85</name>
  </wpt>
  <wpt lat="28.05474" lon="-17.31255">
  <name>WP86</name>
  </wpt>
  <wpt lat="28.05424" lon="-17.31273">
  <name>WP87</name>
  </wpt>
  <wpt lat="28.05386" lon="-17.31255">
  <name>WP88</name>
  </wpt>
  <wpt lat="28.05345" lon="-17.31187">
  <name>WP89</name>
  </wpt>
  <wpt lat="28.05299" lon="-17.31122">
  <name>WP90</name>
  </wpt>
  <wpt lat="28.05254" lon="-17.31075">
  <name>WP91</name>
  </wpt>
  <wpt lat="28.05201" lon="-17.31015">
  <name>WP92</name>
  </wpt>
  <wpt lat="28.05212" lon="-17.30946">
  <name>WP93</name>
  </wpt>
  <wpt lat="28.05197" lon="-17.30873">
  <name>WP94</name>
  </wpt>
  <wpt lat="28.05159" lon="-17.30869">
  <name>WP95</name>
  </wpt>
  <wpt lat="28.05148" lon="-17.30839">
  <name>WP96</name>
  </wpt>
  <wpt lat="28.05144" lon="-17.308">
  <name>WP97</name>
  </wpt>
  <wpt lat="28.0514" lon="-17.30762">
  <name>WP98</name>
  </wpt>
  <wpt lat="28.05186" lon="-17.30684">
  <name>WP99</name>
  </wpt>
  <wpt lat="28.05197" lon="-17.30607">
  <name>WP100</name>
  </wpt>
  <wpt lat="28.05163" lon="-17.30543">
  <name>WP101</name>
  </wpt>
  <wpt lat="28.05152" lon="-17.30453">
  <name>WP102</name>
  </wpt>
  <wpt lat="28.05133" lon="-17.30371">
  <name>WP103</name>
  </wpt>
  <wpt lat="28.05099" lon="-17.30324">
  <name>WP104</name>
  </wpt>
  <wpt lat="28.05061" lon="-17.30311">
  <name>WP105</name>
  </wpt>
  <wpt lat="28.05031" lon="-17.30324">
  <name>WP106</name>
  </wpt>
  <wpt lat="28.05" lon="-17.30294">
  <name>WP107</name>
  </wpt>
  <wpt lat="28.04944" lon="-17.30225">
  <name>WP108</name>
  </wpt>
  <wpt lat="28.04917" lon="-17.30186">
  <name>WP109</name>
  </wpt>
  <wpt lat="28.04921" lon="-17.30079">
  <name>WP110</name>
  </wpt>
  <wpt lat="28.04993" lon="-17.2995">
  <name>WP111</name>
  </wpt>
  <wpt lat="28.05019" lon="-17.29877">
  <name>WP112</name>
  </wpt>
  <wpt lat="28.05004" lon="-17.29817">
  <name>WP113</name>
  </wpt>
  <wpt lat="28.04932" lon="-17.29761">
  <name>WP114</name>
  </wpt>
  <wpt lat="28.04902" lon="-17.29706">
  <name>WP115</name>
  </wpt>
  <wpt lat="28.04875" lon="-17.29676">
  <name>WP116</name>
  </wpt>
  <wpt lat="28.04841" lon="-17.29637">
  <name>WP117</name>
  </wpt>
  <wpt lat="28.04773" lon="-17.29577">
  <name>WP118</name>
  </wpt>
  <wpt lat="28.04735" lon="-17.2953">
  <name>WP119</name>
  </wpt>
  <wpt lat="28.04698" lon="-17.29465">
  <name>WP120</name>
  </wpt>
  <wpt lat="28.04682" lon="-17.29457">
  <name>WP121</name>
  </wpt>
  <wpt lat="28.04637" lon="-17.29397">
  <name>WP122</name>
  </wpt>
  <wpt lat="28.04637" lon="-17.29341">
  <name>WP123</name>
  </wpt>
  <wpt lat="28.0466" lon="-17.29281">
  <name>WP124</name>
  </wpt>
  <wpt lat="28.04675" lon="-17.29216">
  <name>WP125</name>
  </wpt>
  <wpt lat="28.0469" lon="-17.2916">
  <name>WP126</name>
  </wpt>
  <wpt lat="28.04645" lon="-17.29109">
  <name>WP127</name>
  </wpt>
  <wpt lat="28.04607" lon="-17.29066">
  <name>WP128</name>
  </wpt>
  <wpt lat="28.04561" lon="-17.29045">
  <name>WP129</name>
  </wpt>
  <wpt lat="28.04486" lon="-17.29057">
  <name>WP130</name>
  </wpt>
  <wpt lat="28.04383" lon="-17.29075">
  <name>WP131</name>
  </wpt>
  <wpt lat="28.04311" lon="-17.29087">
  <name>WP132</name>
  </wpt>
  <wpt lat="28.04213" lon="-17.29066">
  <name>WP133</name>
  </wpt>
  <wpt lat="28.04137" lon="-17.29027">
  <name>WP134</name>
  </wpt>
  <wpt lat="28.04027" lon="-17.28963">
  <name>WP135</name>
  </wpt>
  <wpt lat="28.03948" lon="-17.28911">
  <name>WP136</name>
  </wpt>
  <wpt lat="28.03846" lon="-17.28937">
  <name>WP137</name>
  </wpt>
  <wpt lat="28.03804" lon="-17.28937">
  <name>WP138</name>
  </wpt>
  <wpt lat="28.03793" lon="-17.28886">
  <name>WP139</name>
  </wpt>
  <wpt lat="28.03838" lon="-17.28808">
  <name>WP140</name>
  </wpt>
  <wpt lat="28.03884" lon="-17.28718">
  <name>WP141</name>
  </wpt>
  <wpt lat="28.0391" lon="-17.28641">
  <name>WP142</name>
  </wpt>
  <wpt lat="28.03876" lon="-17.28611">
  <name>WP143</name>
  </wpt>
  <wpt lat="28.03854" lon="-17.28587">
  <name>WP144</name>
  </wpt>
  <wpt lat="28.03861" lon="-17.28487">
  <name>WP145</name>
  </wpt>
  <wpt lat="28.03876" lon="-17.28414">
  <name>WP146</name>
  </wpt>
  <wpt lat="28.03853" lon="-17.28366">
  <name>WP147</name>
  </wpt>
  <wpt lat="28.03778" lon="-17.28358">
  <name>WP148</name>
  </wpt>
  <wpt lat="28.03823" lon="-17.28255">
  <name>WP149</name>
  </wpt>
  <wpt lat="28.03868" lon="-17.28165">
  <name>WP150</name>
  </wpt>
  <wpt lat="28.03838" lon="-17.28083">
  <name>WP151</name>
  </wpt>
  <wpt lat="28.03823" lon="-17.28036">
  <name>WP152</name>
  </wpt>
  <wpt lat="28.03815" lon="-17.27971">
  <name>WP153</name>
  </wpt>
  <wpt lat="28.03755" lon="-17.28014">
  <name>WP154</name>
  </wpt>
  <wpt lat="28.03725" lon="-17.2798">
  <name>WP155</name>
  </wpt>
  <wpt lat="28.03672" lon="-17.2795">
  <name>WP156</name>
  </wpt>
  <wpt lat="28.03668" lon="-17.27911">
  <name>WP157</name>
  </wpt>
  <wpt lat="28.03672" lon="-17.27834">
  <name>WP158</name>
  </wpt>
  <wpt lat="28.03675" lon="-17.27757">
  <name>WP159</name>
  </wpt>
  <wpt lat="28.03656" lon="-17.27662">
  <name>WP160</name>
  </wpt>
  <wpt lat="28.03596" lon="-17.27606">
  <name>WP161</name>
  </wpt>
  <wpt lat="28.03581" lon="-17.27568">
  <name>WP162</name>
  </wpt>
  <wpt lat="28.03577" lon="-17.27508">
  <name>WP163</name>
  </wpt>
  <wpt lat="28.03603" lon="-17.27422">
  <name>WP164</name>
  </wpt>
  <wpt lat="28.03607" lon="-17.27332">
  <name>WP165</name>
  </wpt>
  <wpt lat="28.03581" lon="-17.27293">
  <name>WP166</name>
  </wpt>
  <wpt lat="28.03535" lon="-17.27276">
  <name>WP167</name>
  </wpt>
  <wpt lat="28.03486" lon="-17.2728">
  <name>WP168</name>
  </wpt>
  <wpt lat="28.03426" lon="-17.27323">
  <name>WP169</name>
  </wpt>
  <wpt lat="28.03323" lon="-17.27375">
  <name>WP170</name>
  </wpt>
  <wpt lat="28.03232" lon="-17.27366">
  <name>WP171</name>
  </wpt>
  <wpt lat="28.03145" lon="-17.27357">
  <name>WP172</name>
  </wpt>
  <wpt lat="28.03081" lon="-17.27357">
  <name>WP173</name>
  </wpt>
  <wpt lat="28.03039" lon="-17.27327">
  <name>WP174</name>
  </wpt>
  <wpt lat="28.03005" lon="-17.27272">
  <name>WP175</name>
  </wpt>
  <wpt lat="28.02945" lon="-17.27293">
  <name>WP176</name>
  </wpt>
  <wpt lat="28.02873" lon="-17.2731">
  <name>WP177</name>
  </wpt>
  <wpt lat="28.02782" lon="-17.27233">
  <name>WP178</name>
  </wpt>
  <wpt lat="28.0274" lon="-17.27259">
  <name>WP179</name>
  </wpt>
  <wpt lat="28.0271" lon="-17.27254">
  <name>WP180</name>
  </wpt>
  <wpt lat="28.02661" lon="-17.27186">
  <name>WP181</name>
  </wpt>
  <wpt lat="28.02619" lon="-17.27156">
  <name>WP182</name>
  </wpt>
  <wpt lat="28.02596" lon="-17.27121">
  <name>WP183</name>
  </wpt>
  <wpt lat="28.02562" lon="-17.27104">
  <name>WP184</name>
  </wpt>
  <wpt lat="28.02528" lon="-17.2704">
  <name>WP185</name>
  </wpt>
  <wpt lat="28.02483" lon="-17.26941">
  <name>WP186</name>
  </wpt>
  <wpt lat="28.02494" lon="-17.26812">
  <name>WP187</name>
  </wpt>
  <wpt lat="28.0249" lon="-17.26757">
  <name>WP188</name>
  </wpt>
  <wpt lat="28.02487" lon="-17.26696">
  <name>WP189</name>
  </wpt>
  <wpt lat="28.02468" lon="-17.26602">
  <name>WP190</name>
  </wpt>
  <wpt lat="28.0254" lon="-17.26482">
  <name>WP191</name>
  </wpt>
  <wpt lat="28.0257" lon="-17.26332">
  <name>WP192</name>
  </wpt>
  <wpt lat="28.02566" lon="-17.26151">
  <name>WP193</name>
  </wpt>
  <wpt lat="28.02551" lon="-17.2604">
  <name>WP194</name>
  </wpt>
  <wpt lat="28.02528" lon="-17.25928">
  <name>WP195</name>
  </wpt>
  <wpt lat="28.02547" lon="-17.25795">
  <name>WP196</name>
  </wpt>
  <wpt lat="28.02649" lon="-17.2564">
  <name>WP197</name>
  </wpt>
  <wpt lat="28.02593" lon="-17.25585">
  <name>WP198</name>
  </wpt>
  <wpt lat="28.02562" lon="-17.25503">
  <name>WP199</name>
  </wpt>
  <wpt lat="28.02577" lon="-17.254">
  <name>WP200</name>
  </wpt>
  <wpt lat="28.02574" lon="-17.25284">
  <name>WP201</name>
  </wpt>
  <wpt lat="28.02547" lon="-17.25181">
  <name>WP202</name>
  </wpt>
  <wpt lat="28.02502" lon="-17.25031">
  <name>WP203</name>
  </wpt>
  <wpt lat="28.02415" lon="-17.24984">
  <name>WP204</name>
  </wpt>
  <wpt lat="28.02316" lon="-17.24936">
  <name>WP205</name>
  </wpt>
  <wpt lat="28.02229" lon="-17.24945">
  <name>WP206</name>
  </wpt>
  <wpt lat="28.02172" lon="-17.24863">
  <name>WP207</name>
  </wpt>
  <wpt lat="28.02172" lon="-17.2476">
  <name>WP208</name>
  </wpt>
  <wpt lat="28.02169" lon="-17.24683">
  <name>WP209</name>
  </wpt>
  <wpt lat="28.02142" lon="-17.2461">
  <name>WP210</name>
  </wpt>
  <wpt lat="28.021" lon="-17.24584">
  <name>WP211</name>
  </wpt>
  <wpt lat="28.02032" lon="-17.24524">
  <name>WP212</name>
  </wpt>
  <wpt lat="28.0201" lon="-17.24481">
  <name>WP213</name>
  </wpt>
  <wpt lat="28.01998" lon="-17.24378">
  <name>WP214</name>
  </wpt>
  <wpt lat="28.0201" lon="-17.2428">
  <name>WP215</name>
  </wpt>
  <wpt lat="28.02059" lon="-17.24232">
  <name>WP216</name>
  </wpt>
  <wpt lat="28.02047" lon="-17.24129">
  <name>WP217</name>
  </wpt>
  <wpt lat="28.02097" lon="-17.23988">
  <name>WP218</name>
  </wpt>
  <wpt lat="28.02153" lon="-17.23928">
  <name>WP219</name>
  </wpt>
  <wpt lat="28.02165" lon="-17.23837">
  <name>WP220</name>
  </wpt>
  <wpt lat="28.0218" lon="-17.23726">
  <name>WP221</name>
  </wpt>
  <wpt lat="28.02214" lon="-17.23649">
  <name>WP222</name>
  </wpt>
  <wpt lat="28.02225" lon="-17.23515">
  <name>WP223</name>
  </wpt>
  <wpt lat="28.02233" lon="-17.23447">
  <name>WP224</name>
  </wpt>
  <wpt lat="28.024" lon="-17.23503">
  <name>WP225</name>
  </wpt>
  <wpt lat="28.02521" lon="-17.23421">
  <name>WP226</name>
  </wpt>
  <wpt lat="28.02536" lon="-17.23339">
  <name>WP227</name>
  </wpt>
  <wpt lat="28.0254" lon="-17.23206">
  <name>WP228</name>
  </wpt>
  <wpt lat="28.02559" lon="-17.23082">
  <name>WP229</name>
  </wpt>
  <wpt lat="28.02585" lon="-17.22966">
  <name>WP230</name>
  </wpt>
  <wpt lat="28.02646" lon="-17.22811">
  <name>WP231</name>
  </wpt>
  <wpt lat="28.02638" lon="-17.2273">
  <name>WP232</name>
  </wpt>
  <wpt lat="28.02574" lon="-17.22618">
  <name>WP233</name>
  </wpt>
  <wpt lat="28.02562" lon="-17.22571">
  <name>WP234</name>
  </wpt>
  <wpt lat="28.02543" lon="-17.22489">
  <name>WP235</name>
  </wpt>
  <wpt lat="28.02555" lon="-17.22365">
  <name>WP236</name>
  </wpt>
  <wpt lat="28.02555" lon="-17.22296">
  <name>WP237</name>
  </wpt>
  <wpt lat="28.02559" lon="-17.2215">
  <name>WP238</name>
  </wpt>
  <wpt lat="28.02562" lon="-17.21979">
  <name>WP239</name>
  </wpt>
  <wpt lat="28.02509" lon="-17.21919">
  <name>WP240</name>
  </wpt>
  <wpt lat="28.02551" lon="-17.21764">
  <name>WP241</name>
  </wpt>
  <wpt lat="28.02593" lon="-17.21691">
  <name>WP242</name>
  </wpt>
  <wpt lat="28.02725" lon="-17.21554">
  <name>WP243</name>
  </wpt>
  <wpt lat="28.02755" lon="-17.21438">
  <name>WP244</name>
  </wpt>
  <wpt lat="28.0274" lon="-17.21318">
  <name>WP245</name>
  </wpt>
  <wpt lat="28.02736" lon="-17.21215">
  <name>WP246</name>
  </wpt>
  <wpt lat="28.02714" lon="-17.21099">
  <name>WP247</name>
  </wpt>
  <wpt lat="28.02642" lon="-17.20991">
  <name>WP248</name>
  </wpt>
  <wpt lat="28.02574" lon="-17.20961">
  <name>WP249</name>
  </wpt>
  <wpt lat="28.02471" lon="-17.20905">
  <name>WP250</name>
  </wpt>
  <wpt lat="28.02437" lon="-17.20832">
  <name>WP251</name>
  </wpt>
  <wpt lat="28.0243" lon="-17.20669">
  <name>WP252</name>
  </wpt>
  <wpt lat="28.02418" lon="-17.20549">
  <name>WP253</name>
  </wpt>
  <wpt lat="28.02411" lon="-17.20399">
  <name>WP254</name>
  </wpt>
  <wpt lat="28.02392" lon="-17.20283">
  <name>WP255</name>
  </wpt>
  <wpt lat="28.02362" lon="-17.20176">
  <name>WP256</name>
  </wpt>
  <wpt lat="28.02418" lon="-17.20081">
  <name>WP257</name>
  </wpt>
  <wpt lat="28.02407" lon="-17.19974">
  <name>WP258</name>
  </wpt>
  <wpt lat="28.02396" lon="-17.19837">
  <name>WP259</name>
  </wpt>
  <wpt lat="28.02581" lon="-17.19785">
  <name>WP260</name>
  </wpt>
  
  <wpt lat="28.08233" lon="-17.3321">
<name>WP01-A</name>
</wpt>
<wpt lat="28.08184" lon="-17.33283">
<name>WP02-B</name>
</wpt>
<wpt lat="28.08136" lon="-17.33287">
<name>WP03-C</name>
</wpt>
<wpt lat="28.08017" lon="-17.33122">
<name>WP04-D</name>
</wpt>
<wpt lat="28.07989" lon="-17.33139">
<name>WP05-E</name>
</wpt>
<wpt lat="28.08074" lon="-17.33253">
<name>WP06-F</name>
</wpt>
<wpt lat="28.0804" lon="-17.3332">
<name>WP07-G</name>
</wpt>
<wpt lat="28.07981" lon="-17.3332">
<name>WP08-H</name>
</wpt>
<wpt lat="28.07949" lon="-17.33302">
<name>WP09-I</name>
</wpt>
<wpt lat="28.07925" lon="-17.33279">
<name>WP10-J</name>
</wpt>
<wpt lat="28.07908" lon="-17.33298">
<name>WP11-K</name>
</wpt>
<wpt lat="28.07809" lon="-17.33062">
<name>WP12-L</name>
</wpt>
<wpt lat="28.07796" lon="-17.33088">
<name>WP13-M</name>
</wpt>
<wpt lat="28.07934" lon="-17.33403">
<name>WP14-N</name>
</wpt>
<wpt lat="28.08034" lon="-17.33403">
<name>WP15-O</name>
</wpt>
<wpt lat="28.08118" lon="-17.33453">
<name>WP16-P</name>
</wpt>
<wpt lat="28.08231" lon="-17.33476">
<name>WP17-Q</name>
</wpt>
<wpt lat="28.0835" lon="-17.33618">
<name>WP18-R</name>
</wpt>
<wpt lat="28.08316" lon="-17.33566">
<name>WP19-S</name>
</wpt>
<wpt lat="28.08441" lon="-17.3371">
<name>WP20-T</name>
</wpt>
<wpt lat="28.08462" lon="-17.33787">
<name>WP21-U</name>
</wpt>
<wpt lat="28.08557" lon="-17.33738">
<name>WP22-V</name>
</wpt>
<wpt lat="28.08585" lon="-17.33781">
<name>WP23-W</name>
</wpt>
<wpt lat="28.08575" lon="-17.33807">
<name>WP24-X</name>
</wpt>
<wpt lat="28.08583" lon="-17.33867">
<name>WP25-Y</name>
</wpt>
<wpt lat="28.086" lon="-17.33923">
<name>WP26-Z</name>
</wpt>
<wpt lat="28.08706" lon="-17.33953">
<name>WP27</name>
</wpt>
<wpt lat="28.08795" lon="-17.33981">
<name>WP28</name>
</wpt>
<wpt lat="28.08888" lon="-17.33957">
<name>WP29</name>
</wpt>
<wpt lat="28.0903" lon="-17.33983">
<name>WP30</name>
</wpt>
<wpt lat="28.09001" lon="-17.33974">
<name>WP31</name>
</wpt>
<wpt lat="28.09149" lon="-17.34036">
<name>WP32</name>
</wpt>
<wpt lat="28.09247" lon="-17.34069">
<name>WP33</name>
</wpt>
<wpt lat="28.09361" lon="-17.34129">
<name>WP34</name>
</wpt>
<wpt lat="28.09442" lon="-17.34197">
<name>WP35</name>
</wpt>
<wpt lat="28.09472" lon="-17.34249">
<name>WP36</name>
</wpt>
<wpt lat="28.09448" lon="-17.34292">
<name>WP37</name>
</wpt>
<wpt lat="28.09444" lon="-17.34309">
<name>WP38</name>
</wpt>
<wpt lat="28.0944" lon="-17.34369">
<name>WP39</name>
</wpt>
<wpt lat="28.09436" lon="-17.34418">
<name>WP40</name>
</wpt>
<wpt lat="28.09431" lon="-17.34438">
<name>WP41</name>
</wpt>
<wpt lat="28.09497" lon="-17.34479">
<name>WP42</name>
</wpt>
<wpt lat="28.09559" lon="-17.34472">
<name>WP43</name>
</wpt>
<wpt lat="28.09585" lon="-17.34532">
<name>WP44</name>
</wpt>
<wpt lat="28.09612" lon="-17.3456">
<name>WP45</name>
</wpt>
<wpt lat="28.09634" lon="-17.34601">
<name>WP46</name>
</wpt>
<wpt lat="28.09635" lon="-17.34683">
<name>WP47</name>
</wpt>
<wpt lat="28.09632" lon="-17.34654">
<name>WP48</name>
</wpt>
<wpt lat="28.0967" lon="-17.34736">
<name>WP49</name>
</wpt>
<wpt lat="28.09695" lon="-17.34772">
<name>WP50</name>
</wpt>
<wpt lat="28.09726" lon="-17.34796">
<name>WP51</name>
</wpt>
<wpt lat="28.09744" lon="-17.34822">
<name>WP52</name>
</wpt>
<wpt lat="28.09783" lon="-17.3485">
<name>WP53</name>
</wpt>
<wpt lat="28.09791" lon="-17.34874">
<name>WP54</name>
</wpt>
<wpt lat="28.09822" lon="-17.34893">
<name>WP55</name>
</wpt>
<wpt lat="28.09868" lon="-17.34888">
<name>WP56</name>
</wpt>
<wpt lat="28.0991" lon="-17.34866">
<name>WP57</name>
</wpt>
<wpt lat="28.0996" lon="-17.34882">
<name>WP58</name>
</wpt>
<wpt lat="28.09984" lon="-17.34849">
<name>WP59</name>
</wpt>
<wpt lat="28.09993" lon="-17.34816">
<name>WP60</name>
</wpt>
<wpt lat="28.10042" lon="-17.34782">
<name>WP61</name>
</wpt>
<wpt lat="28.10079" lon="-17.34756">
<name>WP62</name>
</wpt>
<wpt lat="28.10131" lon="-17.34723">
<name>WP63</name>
</wpt>
<wpt lat="28.10201" lon="-17.34717">
<name>WP64</name>
</wpt>
<wpt lat="28.10255" lon="-17.34714">
<name>WP65</name>
</wpt>
<wpt lat="28.10317" lon="-17.34694">
<name>WP66</name>
</wpt>
<wpt lat="28.10368" lon="-17.34692">
<name>WP67</name>
</wpt>
<wpt lat="28.10414" lon="-17.34685">
<name>WP68</name>
</wpt>
<wpt lat="28.10483" lon="-17.34662">
<name>WP69</name>
</wpt>
<wpt lat="28.10552" lon="-17.34669">
<name>WP70</name>
</wpt>
<wpt lat="28.1046" lon="-17.34666">
<name>WP71</name>
</wpt>
<wpt lat="28.10628" lon="-17.34693">
<name>WP72</name>
</wpt>
<wpt lat="28.10666" lon="-17.34715">
<name>WP73</name>
</wpt>
<wpt lat="28.10725" lon="-17.34706">
<name>WP74</name>
</wpt>
<wpt lat="28.10801" lon="-17.34692">
<name>WP75</name>
</wpt>
<wpt lat="28.10854" lon="-17.34692">
<name>WP76</name>
</wpt>
<wpt lat="28.10906" lon="-17.34681">
<name>WP77</name>
</wpt>
<wpt lat="28.10956" lon="-17.34694">
<name>WP78</name>
</wpt>
<wpt lat="28.11034" lon="-17.34704">
<name>WP79</name>
</wpt>
<wpt lat="28.11085" lon="-17.3471">
<name>WP80</name>
</wpt>
<wpt lat="28.11163" lon="-17.34722">
<name>WP81</name>
</wpt>
<wpt lat="28.11218" lon="-17.34737">
<name>WP82</name>
</wpt>
<wpt lat="28.11263" lon="-17.34791">
<name>WP83</name>
</wpt>
<wpt lat="28.11269" lon="-17.34724">
<name>WP84</name>
</wpt>
<wpt lat="28.11326" lon="-17.34723">
<name>WP85</name>
</wpt>
<wpt lat="28.11353" lon="-17.34674">
<name>WP86</name>
</wpt>
<wpt lat="28.1145" lon="-17.34657">
<name>WP87</name>
</wpt>
<wpt lat="28.11497" lon="-17.34647">
<name>WP88</name>
</wpt>
<wpt lat="28.11587" lon="-17.34659">
<name>WP89</name>
</wpt>
<wpt lat="28.11649" lon="-17.34686">
<name>WP90</name>
</wpt>
<wpt lat="28.11707" lon="-17.34721">
<name>WP91</name>
</wpt>
<wpt lat="28.11701" lon="-17.34775">
<name>WP92</name>
</wpt>
<wpt lat="28.11745" lon="-17.34777">
<name>WP93</name>
</wpt>
<wpt lat="28.11751" lon="-17.34748">
<name>WP94</name>
</wpt>
<wpt lat="28.11802" lon="-17.3475">
<name>WP95</name>
</wpt>
<wpt lat="28.118" lon="-17.34764">
<name>WP96</name>
</wpt>
<wpt lat="28.11838" lon="-17.34768">
<name>WP97</name>
</wpt>
<wpt lat="28.11832" lon="-17.34731">
<name>WP98</name>
</wpt>
<wpt lat="28.11823" lon="-17.34709">
<name>WP99</name>
</wpt>
<wpt lat="28.11839" lon="-17.34664">
<name>WP100</name>
</wpt>
<wpt lat="28.11855" lon="-17.34616">
<name>WP101</name>
</wpt>
<wpt lat="28.11921" lon="-17.34626">
<name>WP102</name>
</wpt>
<wpt lat="28.1195" lon="-17.346">
<name>WP103</name>
</wpt>
<wpt lat="28.11962" lon="-17.34569">
<name>WP104</name>
</wpt>
<wpt lat="28.12015" lon="-17.34576">
<name>WP105</name>
</wpt>
<wpt lat="28.12051" lon="-17.34599">
<name>WP106</name>
</wpt>
<wpt lat="28.12106" lon="-17.34595">
<name>WP107</name>
</wpt>
<wpt lat="28.12131" lon="-17.34571">
<name>WP108</name>
</wpt>
  </gpx>''');

  static double getDistance(Position pos) {
    double result = 0;

    xmlGpx.wpts.forEach((element) {
      double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
          element.lat!,
          element.lon!
      );

      if (result == 0) {
        result = distance;
      } else if (result > distance) {
        result = distance;
      }
    });

    return result;
  }
}