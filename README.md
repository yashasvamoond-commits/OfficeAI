# OfficeCLI Android port status

**The full Android port has not been built yet.** The APK previously produced here is only an offline reference guide; it does not run OfficeCLI or create, edit, or render Office documents. Do not install it expecting OfficeCLI functionality.

The intended target is local/on-device use on the Lenovo Yoga Tab Plus. The upstream [iOfficeAI/OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) is a .NET desktop command-line application, so achieving parity requires porting its engine and replacing desktop-specific process, file-selection, and preview integrations. It cannot be made functional by repackaging the current desktop binary.

The existing reference APK and its build sources remain in this branch, but are not the requested working app. A genuine Android port requires further implementation and testing on an Android device.
