package dm_hibernate_adapter;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.security.ProtectionDomain;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

public class JRubyClassLoader extends ClassLoader {
    private org.jruby.util.JRubyClassLoader jrubyClassloader;
    private Map<String, Class<?>> map = new HashMap<String, Class<?>>();
    
    public JRubyClassLoader(org.jruby.util.JRubyClassLoader jcl){
        this.jrubyClassloader = jcl;
    }
        
    public void register(Class<?> clazz){
        map.put(clazz.getName(), clazz);
    }
    
    public void clear(){
        map.clear();
    }
    
    @Override
    public Class<?> loadClass(String name) throws ClassNotFoundException {
        if(map.containsKey(name)){
            return map.get(name);
        }
        return jrubyClassloader.loadClass(name);
    }

    public void addURL(URL url) {
        jrubyClassloader.addURL(url);
    }

    public void clearAssertionStatus() {
        jrubyClassloader.clearAssertionStatus();
    }

    public Class<?> defineClass(String name, byte[] bytes,
            ProtectionDomain domain) {
        return jrubyClassloader.defineClass(name, bytes, domain);
    }

    public Class<?> defineClass(String name, byte[] bytes) {
        return jrubyClassloader.defineClass(name, bytes);
    }

    public boolean equals(Object arg0) {
        return jrubyClassloader.equals(arg0);
    }

    public URL findResource(String resourceName) {
        return jrubyClassloader.findResource(resourceName);
    }

    public Enumeration<URL> findResources(String resourceName)
            throws IOException {
        return jrubyClassloader.findResources(resourceName);
    }

    public Runnable getJDBCDriverUnloader() {
        return jrubyClassloader.getJDBCDriverUnloader();
    }

    public URL getResource(String arg0) {
        return jrubyClassloader.getResource(arg0);
    }

    public InputStream getResourceAsStream(String arg0) {
        return jrubyClassloader.getResourceAsStream(arg0);
    }

    public Enumeration<URL> getResources(String arg0) throws IOException {
        return jrubyClassloader.getResources(arg0);
    }

    public URL[] getURLs() {
        return jrubyClassloader.getURLs();
    }

    public int hashCode() {
        return jrubyClassloader.hashCode();
    }

    public void setClassAssertionStatus(String arg0, boolean arg1) {
        jrubyClassloader.setClassAssertionStatus(arg0, arg1);
    }

    public void setDefaultAssertionStatus(boolean arg0) {
        jrubyClassloader.setDefaultAssertionStatus(arg0);
    }

    public void setPackageAssertionStatus(String arg0, boolean arg1) {
        jrubyClassloader.setPackageAssertionStatus(arg0, arg1);
    }

    public void tearDown(boolean debug) {
        jrubyClassloader.tearDown(debug);
    }

    public String toString() {
        return jrubyClassloader.toString();
    }

}
