package de.saumya.jibernate;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

public class JibernateClassLoader extends ClassLoader {
    
    private ClassLoader classloader;
    private Map<String, Class<?>> map = new HashMap<String, Class<?>>();

    public JibernateClassLoader(ClassLoader cl){
        this.classloader = cl;
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
        return classloader.loadClass(name);
    }

    public void clearAssertionStatus() {
        classloader.clearAssertionStatus();
    }

    public boolean equals(Object obj) {
        return classloader.equals(obj);
    }

    public URL getResource(String name) {
        return classloader.getResource(name);
    }

    public InputStream getResourceAsStream(String name) {
        return classloader.getResourceAsStream(name);
    }

    public Enumeration<URL> getResources(String name) throws IOException {
        return classloader.getResources(name);
    }

    public int hashCode() {
        return classloader.hashCode();
    }

    public void setClassAssertionStatus(String className, boolean enabled) {
        classloader.setClassAssertionStatus(className, enabled);
    }

    public void setDefaultAssertionStatus(boolean enabled) {
        classloader.setDefaultAssertionStatus(enabled);
    }

    public void setPackageAssertionStatus(String packageName, boolean enabled) {
        classloader.setPackageAssertionStatus(packageName, enabled);
    }

    public String toString() {
        return classloader.toString();
    }
    
    
}
