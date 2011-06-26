package de.saumya.jibernate;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.security.ProtectionDomain;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import org.jruby.util.JRubyClassLoader;

public class JibernateJRubyClassLoader extends ClassLoader {
    
    private JRubyClassLoader jrubyClassloader;
    private Map<String, Class<?>> map = new HashMap<String, Class<?>>();

    public JibernateJRubyClassLoader(JRubyClassLoader jcl){
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

    public boolean equals(Object obj) {
        return jrubyClassloader.equals(obj);
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

    public URL getResource(String name) {
        return jrubyClassloader.getResource(name);
    }

    public InputStream getResourceAsStream(String name) {
        return jrubyClassloader.getResourceAsStream(name);
    }

    public Enumeration<URL> getResources(String name) throws IOException {
        return jrubyClassloader.getResources(name);
    }

    public URL[] getURLs() {
        return jrubyClassloader.getURLs();
    }

    public int hashCode() {
        return jrubyClassloader.hashCode();
    }

    public void setClassAssertionStatus(String className, boolean enabled) {
        jrubyClassloader.setClassAssertionStatus(className, enabled);
    }

    public void setDefaultAssertionStatus(boolean enabled) {
        jrubyClassloader.setDefaultAssertionStatus(enabled);
    }

    public void setPackageAssertionStatus(String packageName, boolean enabled) {
        jrubyClassloader.setPackageAssertionStatus(packageName, enabled);
    }

    public void tearDown(boolean debug) {
        jrubyClassloader.tearDown(debug);
    }

    public String toString() {
        return jrubyClassloader.toString();
    }
    
    
}
